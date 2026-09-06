import SwiftUI

struct GameCanvas: View {
    @ObservedObject var engine: GameEngineViewModel

    var body: some View {
        ZStack {
            // Play area background
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(red: 0.05, green: 0.08, blue: 0.15).opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(.cyan.opacity(0.2), lineWidth: 1)
                )
                .overlay(alignment: .top) {
                    Text(engine.state.levelName)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary.opacity(0.5))
                }

            // The engine uses coordinates centered on a fixed 800 × 600 playfield.
            // SwiftUI positions views from the canvas's top-left corner.
            let centerX = engine.canvasSize.width / 2
            let centerY = engine.canvasSize.height / 2

            // Bricks
            ForEach(engine.state.bricks) { brick in
                if brick.alive {
                    brickView(brick: brick)
                        .frame(width: brick.size.x, height: brick.size.y)
                        .position(x: centerX + brick.position.x, y: centerY + brick.position.y)
                }
            }

            // Paddle
            paddleView(paddle: engine.state.paddle)
                .frame(width: engine.state.paddle.width, height: engine.state.paddle.height)
                .position(
                    x: centerX + engine.state.paddle.position.x,
                    y: centerY + engine.state.paddle.position.y
                )

            // Balls
            ForEach(engine.state.balls) { ball in
                if ball.active {
                    ballView(ball: ball)
                        .frame(width: ball.radius * 2, height: ball.radius * 2)
                        .position(x: centerX + ball.position.x, y: centerY + ball.position.y)
                }
            }

            // Power-ups
            ForEach(engine.state.powerUps) { pu in
                if pu.active {
                    powerUpView(pu: pu)
                        .frame(width: pu.size, height: pu.size)
                        .position(x: centerX + pu.position.x, y: centerY + pu.position.y)
                }
            }

            // Particles
            ForEach(engine.state.particles) { p in
                particleView(particle: p)
                    .frame(width: p.size * p.life, height: p.size * p.life)
                    .position(x: centerX + p.position.x, y: centerY + p.position.y)
            }

            // "Press Space or Tap" hint during ready state
            if engine.state.gamePhase == .ready {
                VStack {
                    Spacer()
                    Text("Press Space or Tap")
                        .font(.title3)
                        .foregroundStyle(.secondary.opacity(0.6))
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: engine.state.gamePhase)
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    engine.handleMouseMove(mouseX: Double(value.location.x - engine.canvasSize.width / 2))
                }
                .onEnded { _ in
                    if engine.state.gamePhase == .ready {
                        engine.launchBall()
                    }
                }
        )
        .onTapGesture {
            if engine.state.gamePhase == .ready {
                engine.launchBall()
            }
        }
        .onLongPressGesture {
            engine.handleLaser()
        }
    }

    // MARK: - Brick View

    private func brickView(brick: Brick) -> some View {
        let baseColor: Color = {
            switch brick.type {
            case .normal: return .cyan
            case .hard: return .purple
            case .indestructible: return .gray
            }
        }()

        return RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        baseColor.opacity(min(1.0, brick.opacity * 1.2)),
                        baseColor.opacity(brick.opacity)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(baseColor.opacity(0.3), lineWidth: 0.5)
            )
            .shadow(color: baseColor.opacity(brick.opacity * 0.3), radius: 2, x: 0, y: 1)
            .overlay {
                if brick.type == .indestructible {
                    Rectangle()
                        .fill(.white.opacity(0.15))
                        .frame(height: 1)
                        .offset(y: -2)
                    Rectangle()
                        .fill(.white.opacity(0.15))
                        .frame(height: 1)
                        .offset(y: 2)
                }
            }
    }

    // MARK: - Paddle View

    private func paddleView(paddle: Paddle) -> some View {
        let mainColor: Color = paddle.laserActive ? .yellow : .cyan

        return Capsule(style: .continuous)
            .fill(
                LinearGradient(
                    colors: paddle.laserActive
                        ? [.yellow, .orange]
                        : [.cyan, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .shadow(color: mainColor.opacity(0.5), radius: 6, x: 0, y: 0)
            .overlay(
                Capsule(style: .continuous)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
            .overlay {
                if paddle.laserActive {
                    HStack {
                        Circle().fill(.yellow).frame(width: 4)
                        Spacer()
                        Circle().fill(.yellow).frame(width: 4)
                    }
                    .offset(y: 2)
                }
            }
    }

    // MARK: - Ball View

    private func ballView(ball: Ball) -> some View {
        ZStack {
            // Trail
            ForEach(0..<ball.trail.count, id: \.self) { i in
                let alpha = Double(i) / Double(ball.trail.count) * 0.35
                let radius = CGFloat(ball.radius) * (0.2 + (Double(i) / Double(ball.trail.count)) * 0.8)
                Circle()
                    .fill(.cyan.opacity(alpha))
                    .position(x: ball.trail[i].x, y: ball.trail[i].y)
                    .frame(width: radius * 2, height: radius * 2)
            }

            // Main ball
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white, .cyan],
                        center: .center,
                        startRadius: 0,
                        endRadius: CGFloat(ball.radius)
                    )
                )
                .shadow(color: .cyan.opacity(0.8), radius: 4, x: 0, y: 0)
        }
    }

    // MARK: - PowerUp View

    private func powerUpView(pu: PowerUp) -> some View {
        Circle()
            .fill(pu.type.color.opacity(0.25))
            .overlay {
                Circle()
                    .stroke(pu.type.color, lineWidth: 2)
            }
            .overlay {
                Text(pu.type.symbol)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(pu.type.color)
            }
    }

    // MARK: - Particle View

    private func particleView(particle: Particle) -> some View {
        Circle()
            .fill(particle.color.opacity(max(0, particle.life)))
            .shadow(color: particle.color.opacity(particle.life * 0.5), radius: 1)
    }
}
