import SwiftUI

struct GameHUD: View {
    @ObservedObject var engine: GameEngineViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                // Score
                VStack(alignment: .leading, spacing: 2) {
                    Text("SCORE").font(.caption2).foregroundStyle(.secondary)
                    Text(String(format: "%06d", engine.state.score))
                        .font(.system(.title3, design: .monospaced)).fontWeight(.bold)
                        .foregroundStyle(.cyan.gradient)
                }

                Spacer()

                // Combo
                if engine.state.comboCount > 1 {
                    VStack(alignment: .center, spacing: 2) {
                        Text("COMBO").font(.caption2).foregroundStyle(.secondary)
                        Text("x\(engine.state.comboCount)")
                            .font(.system(.title3, design: .monospaced)).fontWeight(.bold)
                            .foregroundStyle(.orange.gradient)
                    }
                    .scaleEffect(engine.state.comboTimer > 0 ? 1.0 : 0.0)
                    .opacity(engine.state.comboTimer > 0 ? 1.0 : 0.0)
                }

                Spacer()

                // Level
                VStack(alignment: .trailing, spacing: 2) {
                    Text("LEVEL").font(.caption2).foregroundStyle(.secondary)
                    Text("\(engine.state.level + 1)").font(.system(.title3, design: .monospaced)).fontWeight(.bold)
                        .foregroundStyle(.purple.gradient)
                }
            }
            .padding(.top, 12)
            .padding(.horizontal, 16)

            Spacer()

            // Bottom bar
            HStack {
                // Lives
                HStack(spacing: 4) {
                    ForEach(0..<engine.state.lives, id: \.self) { _ in
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(.red.gradient)
                    }
                }

                Spacer()

                // Active power-ups
                HStack(spacing: 8) {
                    let keys = Array(engine.state.activePowerUps.keys)
                    ForEach(keys, id: \.self) { type in
                        VStack(spacing: 2) {
                            Image(systemName: type == .widePaddle ? "arrow.left.right" :
                                  type == .multiBall ? "circle.dashed" :
                                  type == .laser ? "bolt.fill" :
                                  type == .slowBall ? "timer" : "heart.fill")
                                .font(.caption)
                                .foregroundStyle(type.color)
                            if let timeLeft = engine.state.activePowerUps[type] {
                                Text("\(Int(timeLeft))s")
                                    .font(.caption2.monospaced())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Spacer()

                // High score
                VStack(alignment: .trailing, spacing: 2) {
                    Text("BEST").font(.caption2).foregroundStyle(.secondary)
                    Text(String(format: "%06d", engine.state.highScore))
                        .font(.system(.title3, design: .monospaced)).fontWeight(.bold)
                        .foregroundStyle(.green.gradient)
                }
            }
            .padding(.bottom, 12)
            .padding(.horizontal, 16)
        }
    }
}
