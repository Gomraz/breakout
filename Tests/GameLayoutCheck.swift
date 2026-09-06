import Foundation

@main
struct GameLayoutCheck {
    static func main() {
        let engine = GameEngineViewModel()
        engine.startGame()

        precondition(engine.state.paddle.position.y == 260,
                     "Paddle should be at the bottom")
        precondition(engine.state.balls.first?.position.y == 247,
                     "Ball should start above the paddle")
        precondition(engine.state.bricks.first?.position.y == -207,
                     "Bricks should start near the top")
        precondition(Level1.ballSpeed == 420,
                     "Level 1 speed should be 20% faster")
        precondition(Level5.ballSpeed == 540,
                     "Level 5 speed should be 20% faster")

        print("Game layout checks passed")
    }
}