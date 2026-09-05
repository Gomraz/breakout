import SwiftUI

struct ContentView: View {
    @StateObject private var engine = GameEngineViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.08),
                    Color(red: 0.05, green: 0.02, blue: 0.12),
                    Color(red: 0.02, green: 0.02, blue: 0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Game canvas
            GameCanvas(engine: engine)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(.cyan.opacity(0.15), lineWidth: 1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    GeometryReader { geo in
                        Color.clear.onAppear {
                            engine.canvasSize = geo.size
                        }
                    }
                )

            // HUD overlay
            if engine.state.gamePhase == .playing || engine.state.gamePhase == .ready {
                GameHUD(engine: engine)
            }

            // Menu
            if engine.state.gamePhase == .menu {
                MenuView(startGame: { engine.startGame() })
            }

            // Paused
            if engine.state.gamePhase == .paused {
                VStack(spacing: 16) {
                    Text("PAUSED")
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundStyle(.cyan.gradient)
                    Text("Press Space or Tap to resume")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
            }

            // Game Over
            if engine.state.gamePhase == .gameOver {
                GameOverView(
                    score: engine.state.score,
                    highScore: engine.state.highScore,
                    restart: { engine.startGame() }
                )
            }

            // Level Complete
            if engine.state.gamePhase == .levelComplete {
                LevelCompleteView(
                    level: engine.state.level + 1,
                    levelName: engine.state.levelName,
                    score: engine.state.score,
                    nextLevel: { engine.loadNextLevel() }
                )
            }

            // Victory
            if engine.state.gamePhase == .victory {
                VictoryView(
                    score: engine.state.score,
                    highScore: engine.state.highScore,
                    restart: { engine.startGame() }
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: { engine.pauseGame() }) {
                    Image(systemName: engine.state.gamePhase == .paused ? "play.circle" : "pause.circle")
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
        .onKeyPress(.space) {
            if engine.state.gamePhase == .ready {
                engine.launchBall()
            }
            return .handled
        }
        .onAppear {
            engine.startTimer()
        }
    }
}
