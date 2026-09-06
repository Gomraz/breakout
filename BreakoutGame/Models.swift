import SwiftUI
import simd

// MARK: - Vector2 alias for math clarity
typealias Vec2 = SIMD2<Double>

// MARK: - Brick types
enum BrickType: Int, CaseIterable {
    case normal = 0
    case hard = 1
    case indestructible = 2

    var color: Color {
        switch self {
        case .normal:   return .cyan
        case .hard:     return .purple
        case .indestructible: return .gray
        }
    }

    var hitCount: Int {
        switch self {
        case .normal:   return 1
        case .hard:     return 2
        case .indestructible: return Int.max
        }
    }

    var points: Int {
        switch self {
        case .normal:   return 100
        case .hard:     return 150
        case .indestructible: return 0
        }
    }
}

// MARK: - Brick
struct Brick: Identifiable {
    let id = UUID()
    var position: Vec2
    var size: Vec2
    var type: BrickType = .normal
    var currentHitCount: Int = 0
    var alive: Bool = true
    var opacity: Double = 1.0
}

// MARK: - PowerUp types
enum PowerUpType: String, CaseIterable, Hashable, Identifiable {
    var id: String { rawValue }
    case widePaddle    = "W"
    case multiBall     = "M"
    case extraLife     = "L"
    case laser         = "A"
    case slowBall      = "S"

    var color: Color {
        switch self {
        case .widePaddle: return .green
        case .multiBall:  return .orange
        case .extraLife:  return .red
        case .laser:      return .blue
        case .slowBall:   return .yellow
        }
    }

    var symbol: String {
        switch self {
        case .widePaddle: return "⬌"
        case .multiBall:  return "⊕"
        case .extraLife:  return "♥"
        case .laser:      return "⚡"
        case .slowBall:   return "⏱"
        }
    }

    var duration: TimeInterval {
        switch self {
        case .widePaddle: return 10
        case .multiBall:  return 0
        case .extraLife:  return 0
        case .laser:      return 8
        case .slowBall:   return 6
        }
    }
}

// MARK: - PowerUp
struct PowerUp: Identifiable, Hashable {
    let id = UUID()
    var position: Vec2
    var velocity: Vec2
    var size: Double
    var type: PowerUpType
    var active: Bool = true
}

// MARK: - Ball
struct Ball: Identifiable {
    let id = UUID()
    var position: Vec2
    var velocity: Vec2
    var radius: Double
    var active: Bool = true
    var trail: [Vec2] = []
}

// MARK: - Paddle
struct Paddle {
    var position: Vec2
    var width: Double
    var height: Double
    var targetX: Double = 0
    var laserActive: Bool = false
    var lastLaserFire: TimeInterval = 0
}

// MARK: - Particle
struct Particle: Identifiable {
    let id = UUID()
    var position: Vec2
    var velocity: Vec2
    var life: Double
    var maxLife: Double
    var color: Color
    var size: Double
}

// MARK: - GameState
struct GameState {
    var score: Int = 0
    var highScore: Int = 0
    var lives: Int = 3
    var level: Int = 0
    var balls: [Ball] = []
    var bricks: [Brick] = []
    var paddle: Paddle
    var powerUps: [PowerUp] = []
    var particles: [Particle] = []
    var activePowerUps: [PowerUpType: TimeInterval] = [:]
    var gamePhase: GamePhase = .menu
    var levelData: LevelDefinition = Level1
    var shakeAmount: Double = 0
    var comboCount: Int = 0
    var comboTimer: TimeInterval = 0
    var levelName: String = ""

    init() {
        paddle = Paddle(
            position: Vec2(0, 260),
            width: Level1.paddleWidth,
            height: 14
        )
        loadHighScore()
    }

    func saveHighScore() {
        UserDefaults.standard.set(highScore, forKey: "breakout_high_score")
    }

    mutating func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: "breakout_high_score")
    }
}

// MARK: - GamePhase
enum GamePhase: String {
    case menu
    case ready
    case playing
    case paused
    case gameOver
    case levelComplete
    case victory
}

// MARK: - Level Definition
struct LevelDefinition {
    let id: Int
    let name: String
    let gridWidth: Int
    let gridHeight: Int
    let brickRows: [[BrickType]]
    let ballSpeed: Double
    let powerUpChance: Double
    let paddleWidth: Double
}

let Level1 = LevelDefinition(
    id: 1, name: "Warm Up",
    gridWidth: 10, gridHeight: 5,
    brickRows: [
        [.normal,.normal,.normal,.normal,.normal,.normal,.normal,.normal,.normal,.normal],
        [.normal,.normal,.normal,.normal,.normal,.normal,.normal,.normal,.normal,.normal],
        [.normal,.normal,.normal,.normal,.normal,.normal,.normal,.normal,.normal,.normal],
        [.hard,.hard,.hard,.hard,.hard,.hard,.hard,.hard,.hard,.hard],
        [.hard,.hard,.hard,.hard,.hard,.hard,.hard,.hard,.hard,.hard],
    ],
    ballSpeed: 420, powerUpChance: 0.12, paddleWidth: 120
)

let Level2 = LevelDefinition(
    id: 2, name: "Getting Harder",
    gridWidth: 10, gridHeight: 6,
    brickRows: [
        [.hard,.normal,.hard,.normal,.hard,.normal,.hard,.normal,.hard,.normal],
        [.normal,.hard,.normal,.hard,.normal,.hard,.normal,.hard,.normal,.hard],
        [.hard,.hard,.normal,.normal,.hard,.hard,.normal,.normal,.hard,.hard],
        [.normal,.normal,.hard,.hard,.hard,.hard,.hard,.hard,.normal,.normal],
        [.hard,.hard,.normal,.normal,.hard,.hard,.normal,.normal,.hard,.hard],
        [.hard,.normal,.hard,.normal,.hard,.normal,.hard,.normal,.hard,.normal],
    ],
    ballSpeed: 456, powerUpChance: 0.15, paddleWidth: 110
)

let Level3 = LevelDefinition(
    id: 3, name: "Indestructible Wall",
    gridWidth: 10, gridHeight: 6,
    brickRows: [
        [.indestructible,.hard,.hard,.normal,.normal,.normal,.normal,.hard,.hard,.indestructible],
        [.indestructible,.hard,.normal,.normal,.normal,.normal,.normal,.normal,.hard,.indestructible],
        [.hard,.hard,.normal,.normal,.indestructible,.indestructible,.normal,.normal,.hard,.hard],
        [.hard,.normal,.normal,.indestructible,.indestructible,.indestructible,.indestructible,.normal,.normal,.hard],
        [.hard,.normal,.normal,.indestructible,.normal,.normal,.indestructible,.normal,.normal,.hard],
        [.hard,.hard,.normal,.normal,.normal,.normal,.normal,.normal,.hard,.hard],
    ],
    ballSpeed: 480, powerUpChance: 0.18, paddleWidth: 100
)

let Level4 = LevelDefinition(
    id: 4, name: "Pyramid",
    gridWidth: 10, gridHeight: 8,
    brickRows: [
        [.hard,.hard,.hard,.hard,.hard,.hard,.hard,.hard,.hard,.hard],
        [.normal,.normal,.normal,.normal,.normal,.normal,.normal,.normal,.normal,.normal],
        [.normal,.normal,.normal,.normal,.normal,.normal,.normal,.normal,.normal,.normal],
        [.hard,.normal,.normal,.hard,.hard,.hard,.hard,.normal,.normal,.hard],
        [.hard,.normal,.normal,.hard,.normal,.normal,.hard,.normal,.normal,.hard],
        [.hard,.normal,.normal,.hard,.normal,.normal,.hard,.normal,.normal,.hard],
        [.normal,.normal,.normal,.hard,.hard,.hard,.hard,.normal,.normal,.normal],
        [.hard,.hard,.hard,.normal,.normal,.normal,.normal,.hard,.hard,.hard],
    ],
    ballSpeed: 504, powerUpChance: 0.20, paddleWidth: 95
)

let Level5 = LevelDefinition(
    id: 5, name: "The Gauntlet",
    gridWidth: 10, gridHeight: 7,
    brickRows: [
        [.hard,.indestructible,.normal,.hard,.normal,.normal,.hard,.normal,.indestructible,.hard],
        [.indestructible,.hard,.hard,.normal,.normal,.normal,.normal,.hard,.hard,.indestructible],
        [.normal,.hard,.indestructible,.normal,.normal,.normal,.normal,.indestructible,.hard,.normal],
        [.hard,.normal,.normal,.normal,.indestructible,.indestructible,.normal,.normal,.normal,.hard],
        [.hard,.normal,.normal,.indestructible,.normal,.normal,.indestructible,.normal,.normal,.hard],
        [.normal,.hard,.indestructible,.normal,.normal,.normal,.normal,.indestructible,.hard,.normal],
        [.hard,.indestructible,.normal,.hard,.normal,.normal,.hard,.normal,.indestructible,.hard],
    ],
    ballSpeed: 540, powerUpChance: 0.22, paddleWidth: 90
)

let AllLevels: [LevelDefinition] = [Level1, Level2, Level3, Level4, Level5]
