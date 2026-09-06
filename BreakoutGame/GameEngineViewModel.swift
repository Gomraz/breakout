import Foundation
import SwiftUI
import Combine

class GameEngineViewModel: ObservableObject {
    @Published var state: GameState
    @Published var canvasSize: CGSize = .zero
    private var timer: Timer?

    init() {
        state = GameState()
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.update()
        }
    }

    func startGame() {
        state.score = 0
        state.lives = 3
        state.level = 0
        state.comboCount = 0
        state.comboTimer = 0
        state.paddle = Paddle(
            position: Vec2(0, 260),
            width: Level1.paddleWidth,
            height: 14
        )
        loadLevel(levelIndex: 0)
    }

    func loadLevel(levelIndex: Int) {
        let level = AllLevels[levelIndex]
        state.level = levelIndex
        state.levelData = level
        state.levelName = level.name

        let brickWidth: Double = 72.0
        let brickHeight: Double = 26.0
        let brickGap: Double = 3.0
        let totalWidth = Double(level.gridWidth) * (brickWidth + brickGap) - brickGap

        var bricks: [Brick] = []
        for row in 0..<level.brickRows.count {
            for col in 0..<level.brickRows[row].count {
                let type = level.brickRows[row][col]
                let x = -totalWidth / 2.0 + Double(col) * (brickWidth + brickGap) + brickWidth / 2.0
                let y = -220.0 + Double(row) * (brickHeight + brickGap) + brickHeight / 2.0
                bricks.append(Brick(
                    position: Vec2(x, y),
                    size: Vec2(brickWidth, brickHeight),
                    type: type,
                    currentHitCount: 0,
                    alive: true
                ))
            }
        }

        state.bricks = bricks
        state.paddle.width = level.paddleWidth
        state.paddle.position.x = 0
        state.paddle.targetX = 0
        state.gamePhase = .ready
        state.balls = [Ball(
            position: Vec2(0, 247),
            velocity: .zero,
            radius: 6,
            trail: []
        )]
        state.powerUps = []
        state.particles = []
        state.activePowerUps = [:]
        state.shakeAmount = 0
    }

    func loadNextLevel() {
        let nextLevel = state.level + 1
        if nextLevel < AllLevels.count {
            loadLevel(levelIndex: nextLevel)
        }
    }

    func launchBall() {
        guard state.gamePhase == .ready else { return }
        state.gamePhase = .playing
        for i in state.balls.indices {
            let angle: Double = -.pi / 2.0 + (Double.random(in: -0.2...0.2))
            let speed = state.levelData.ballSpeed
            state.balls[i].velocity = Vec2(cos(angle) * speed, sin(angle) * speed)
        }
    }

    func pauseGame() {
        if state.gamePhase == .playing {
            state.gamePhase = .paused
        } else if state.gamePhase == .paused {
            state.gamePhase = .playing
        }
    }

    func handleMouseMove(mouseX: Double) {
        let halfWidth = state.paddle.width / 2.0 + 10.0
        let playWidth: Double = 400.0
        state.paddle.targetX = max(-playWidth + halfWidth, min(playWidth - halfWidth, mouseX))
    }

    func handleLaser() {
        guard state.gamePhase == .playing,
              state.activePowerUps[.laser] != nil,
              Date().timeIntervalSince1970 - state.paddle.lastLaserFire > 0.15
        else { return }

        state.paddle.lastLaserFire = Date().timeIntervalSince1970

        for i in state.balls.indices {
            var ball = state.balls[i]
            ball.velocity.y += 200.0
            state.balls[i] = ball
        }

        for _ in 0..<4 {
            let angle = Double.random(in: (-Double.pi)...(-Double.pi / 2.0))
            let x1 = state.paddle.position.x - state.paddle.width / 2.0
            state.particles.append(Particle(
                position: Vec2(x1, state.paddle.position.y),
                velocity: Vec2(cos(angle) * 200, sin(angle) * 200),
                life: 1.0,
                maxLife: 0.15,
                color: .yellow,
                size: 3
            ))
        }

        for _ in 0..<4 {
            let angle = Double.random(in: (-Double.pi / 2.0)...0)
            let x2 = state.paddle.position.x + state.paddle.width / 2.0
            state.particles.append(Particle(
                position: Vec2(x2, state.paddle.position.y),
                velocity: Vec2(cos(angle) * 200, sin(angle) * 200),
                life: 1.0,
                maxLife: 0.15,
                color: .yellow,
                size: 3
            ))
        }
    }

    // MARK: - Main Update Loop

    private func update() {
        guard state.gamePhase == .playing else { return }

        let dt: Double = 1.0 / 60.0

        // Combo timer
        state.comboTimer -= dt
        if state.comboTimer <= 0 {
            state.comboCount = 0
        }

        // Power-up timers
        for key in state.activePowerUps.keys {
            state.activePowerUps[key] = max(0, state.activePowerUps[key]! - dt)
        }
        state.activePowerUps = Dictionary(uniqueKeysWithValues: state.activePowerUps.filter { $0.value > 0 })

        // Paddle smoothing
        let smoothing = 1.0 - pow(0.001, dt)
        state.paddle.position.x += (state.paddle.targetX - state.paddle.position.x) * smoothing

        // Update balls
        for i in state.balls.indices {
            var ball = state.balls[i]

            // Trail
            ball.trail.append(ball.position)
            if ball.trail.count > 8 { ball.trail.removeFirst() }

            // Move
            ball.position += ball.velocity * dt
            let speed = sqrt(ball.velocity.x * ball.velocity.x + ball.velocity.y * ball.velocity.y)

            // Walls
            if ball.position.x < -400.0 + ball.radius {
                ball.position.x = -400.0 + ball.radius
                ball.velocity.x = abs(ball.velocity.x)
            }
            if ball.position.x > 400.0 - ball.radius {
                ball.position.x = 400.0 - ball.radius
                ball.velocity.x = -abs(ball.velocity.x)
            }
            if ball.position.y > 300.0 + ball.radius {
                ball.active = false
                state.balls[i] = ball
                continue
            }
            if ball.position.y < -300.0 + ball.radius {
                ball.position.y = -300.0 + ball.radius
                ball.velocity.y = abs(ball.velocity.y)
            }

            // Paddle collision
            let paddle = state.paddle
            let left = paddle.position.x - paddle.width / 2.0
            let right = paddle.position.x + paddle.width / 2.0
            let paddleTop = paddle.position.y + paddle.height / 2.0

            if ball.velocity.y > 0 &&
               ball.position.x > left - ball.radius &&
               ball.position.x < right + ball.radius &&
               ball.position.y + ball.radius > paddle.position.y - paddle.height / 2.0 &&
               ball.position.y - ball.radius < paddleTop {

                ball.position.y = paddle.position.y - paddle.height / 2.0 - ball.radius
                ball.velocity.y = -abs(ball.velocity.y)

                let hitPos = (ball.position.x - paddle.position.x) / (paddle.width / 2.0)
                let angle = hitPos * Double.pi * 0.35 - Double.pi / 2.0
                let slowMult = state.activePowerUps[.slowBall] != nil ? 0.6 : 1.0
                ball.velocity = Vec2(cos(angle) * speed * slowMult, sin(angle) * speed * slowMult)
            }

            // Brick collisions
            for j in state.bricks.indices {
                var brick = state.bricks[j]
                guard brick.alive else { continue }

                let bx = brick.position.x
                let by = brick.position.y
                let halfW = brick.size.x / 2.0
                let halfH = brick.size.y / 2.0

                let closestX = max(bx - halfW, min(ball.position.x, bx + halfW))
                let closestY = max(by - halfH, min(ball.position.y, by + halfH))
                let dx = ball.position.x - closestX
                let dy = ball.position.y - closestY
                let distSq = dx * dx + dy * dy

                if distSq < ball.radius * ball.radius {
                    ball.velocity.y = -ball.velocity.y
                    ball.position.y += (ball.position.y > by ? 1.0 : -1.0) * 2.0

                    brick.currentHitCount += 1
                    brick.opacity = max(0.3, 1.0 - Double(brick.currentHitCount) * 0.3)

                    if brick.currentHitCount >= brick.type.hitCount {
                        brick.alive = false
                    }

                    state.score += brick.type.points
                    state.comboCount += 1
                    state.comboTimer = 2.0

                    // Spawn particles
                    for _ in 0..<12 {
                        let a = Double.random(in: 0..<2.0 * Double.pi)
                        let s = Double.random(in: 80...250)
                        state.particles.append(Particle(
                            position: brick.position,
                            velocity: Vec2(cos(a) * s, sin(a) * s),
                            life: 1.0,
                            maxLife: 0.5 + Double.random(in: 0...0.3),
                            color: brick.type.color,
                            size: Double.random(in: 2...5)
                        ))
                    }

                    // Power-up drop chance
                    if Double.random(in: 0..<1.0) < state.levelData.powerUpChance && brick.type != .indestructible {
                        let types = PowerUpType.allCases
                        let type = types[Int.random(in: 0..<types.count)]
                        state.powerUps.append(PowerUp(
                            position: brick.position,
                            velocity: Vec2(Double.random(in: -20...20), Double.random(in: 20...40)),
                            size: 18,
                            type: type
                        ))
                    }

                    state.bricks[j] = brick
                    break
                }
            }

            // Power-up collisions
            for k in state.powerUps.indices {
                var pu = state.powerUps[k]
                guard pu.active else { continue }
                let dx = ball.position.x - pu.position.x
                let dy = ball.position.y - pu.position.y
                let dist = sqrt(dx * dx + dy * dy)

                if dist < ball.radius + pu.size / 2.0 {
                    pu.active = false
                    collectPowerUp(pu.type)

                    for _ in 0..<8 {
                        let a = Double.random(in: 0..<2.0 * Double.pi)
                        let s = Double.random(in: 40...120)
                        state.particles.append(Particle(
                            position: pu.position,
                            velocity: Vec2(cos(a) * s, sin(a) * s),
                            life: 1.0,
                            maxLife: 0.3 + Double.random(in: 0...0.2),
                            color: pu.type.color,
                            size: Double.random(in: 2...4)
                        ))
                    }

                    state.powerUps[k] = pu
                    break
                }
            }

            state.balls[i] = ball
        }

        // Dead balls
        let aliveBalls = state.balls.filter { $0.active }
        if aliveBalls.isEmpty {
            state.lives -= 1
            state.shakeAmount = 8
            state.comboCount = 0
            if state.lives <= 0 {
                state.gamePhase = .gameOver
                if state.score > state.highScore {
                    state.highScore = state.score
                    state.saveHighScore()
                }
            } else {
                state.gamePhase = .ready
                state.balls = [Ball(
                    position: Vec2(state.paddle.position.x, state.paddle.position.y - state.paddle.height / 2.0 - 8),
                    velocity: .zero,
                    radius: 6,
                    trail: []
                )]
            }
        } else {
            state.balls = aliveBalls
        }

        // Particles
        for i in state.particles.indices {
            var p = state.particles[i]
            p.life -= dt / p.maxLife
            p.position += p.velocity * dt
            p.velocity.y -= 50.0 * dt
            if p.life <= 0 { state.particles[i].life = -1 }
        }
        state.particles = state.particles.filter { $0.life > 0 }

        // Falling power-ups
        for i in state.powerUps.indices {
            var pu = state.powerUps[i]
            pu.position += pu.velocity * dt
            if pu.position.y > 300 { pu.active = false }
            state.powerUps[i] = pu
        }
        state.powerUps = state.powerUps.filter { $0.active }

        // Shake decay
        if state.shakeAmount > 0 {
            state.shakeAmount -= dt * 20
            if state.shakeAmount < 0 { state.shakeAmount = 0 }
        }

        // Level complete
        let aliveBricks = state.bricks.filter { $0.alive }
        if aliveBricks.isEmpty {
            state.level += 1
            if state.level >= AllLevels.count {
                state.gamePhase = .victory
                if state.score > state.highScore {
                    state.highScore = state.score
                    state.saveHighScore()
                }
            } else {
                state.gamePhase = .levelComplete
            }
        }
    }

    // MARK: - PowerUps

    private func collectPowerUp(_ type: PowerUpType) {
        switch type {
        case .widePaddle:
            state.activePowerUps[.widePaddle] = 10
            state.paddle.width = 160
        case .multiBall:
            let count = state.balls.filter { $0.active }.count
            for _ in 0..<min(count, 3) {
                if let ref = state.balls.first(where: { $0.active }) {
                    let angle = -.pi / 2.0 + Double.random(in: -0.4...0.4)
                    let spd = sqrt(ref.velocity.x * ref.velocity.x + ref.velocity.y * ref.velocity.y)
                    state.balls.append(Ball(
                        position: ref.position,
                        velocity: Vec2(cos(angle) * spd, sin(angle) * spd),
                        radius: 6
                    ))
                }
            }
        case .extraLife:
            state.lives = min(state.lives + 1, 5)
        case .laser:
            state.activePowerUps[.laser] = 8
        case .slowBall:
            state.activePowerUps[.slowBall] = 6
            for i in state.balls.indices {
                var ball = state.balls[i]
                let spd = sqrt(ball.velocity.x * ball.velocity.x + ball.velocity.y * ball.velocity.y)
                if spd > 0 {
                    ball.velocity = Vec2(ball.velocity.x / spd, ball.velocity.y / spd) * spd * 0.6
                }
                state.balls[i] = ball
            }
        }
    }
}
