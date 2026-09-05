import SwiftUI

struct GameOverView: View {
    let score: Int
    let highScore: Int
    let restart: () -> Void

    var body: some View {
        let isNewHigh = score >= highScore && score > 0
        VStack(spacing: 24) {
            Spacer()
            Text("GAME OVER")
                .font(.system(size: 60, weight: .bold, design: .monospaced))
                .foregroundStyle(.red.gradient)
                .shadow(color: .red.opacity(0.3), radius: 20)
            if isNewHigh {
                Text("★ NEW HIGH SCORE ★")
                    .font(.title.bold())
                    .foregroundStyle(.yellow.gradient)
                    .shadow(color: .yellow.opacity(0.5), radius: 10)
            }
            HStack(spacing: 40) {
                VStack {
                    Text("SCORE").font(.caption2).foregroundStyle(.secondary)
                    Text(String(format: "%06d", score))
                        .font(.title.bold().monospaced()).foregroundStyle(.cyan)
                }
                VStack {
                    Text("HIGH SCORE").font(.caption2).foregroundStyle(.secondary)
                    Text(String(format: "%06d", highScore))
                        .font(.title.bold().monospaced()).foregroundStyle(.green)
                }
            }
            Spacer()
            Button(action: restart) {
                Text("PLAY AGAIN")
                    .font(.title2.bold())
                    .frame(width: 240, height: 56)
                    .background(
                        LinearGradient(colors: [.red, .orange],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: .red.opacity(0.3), radius: 10)
            }
            .buttonStyle(ClickEffect())
        }
        .padding(40)
    }
}

struct LevelCompleteView: View {
    let level: Int
    let levelName: String
    let score: Int
    let nextLevel: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("LEVEL COMPLETE")
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundStyle(.green.gradient)
                .shadow(color: .green.opacity(0.3), radius: 20)
            VStack(spacing: 8) {
                Text("Level \(level)").font(.title).fontWeight(.bold).foregroundStyle(.cyan)
                Text(levelName).font(.title3).foregroundStyle(.secondary)
            }
            Text("Score: \(score)").font(.title2.monospaced()).foregroundStyle(.yellow)
            Spacer()
            Button(action: nextLevel) {
                Text("NEXT LEVEL →")
                    .font(.title2.bold())
                    .frame(width: 240, height: 56)
                    .background(
                        LinearGradient(colors: [.green, .cyan],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: .green.opacity(0.3), radius: 10)
            }
            .buttonStyle(ClickEffect())
        }
        .padding(40)
    }
}

struct VictoryView: View {
    let score: Int
    let highScore: Int
    let restart: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(colors: [.yellow, .orange],
                                   startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: .yellow.opacity(0.5), radius: 20)
            Text("VICTORY!")
                .font(.system(size: 60, weight: .bold, design: .monospaced))
                .foregroundStyle(
                    LinearGradient(colors: [.yellow, .orange, .red],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .shadow(color: .yellow.opacity(0.4), radius: 20)
            Text("You conquered all levels!").font(.title2).foregroundStyle(.secondary)
            HStack(spacing: 40) {
                VStack {
                    Text("FINAL SCORE").font(.caption2).foregroundStyle(.secondary)
                    Text(String(format: "%06d", score))
                        .font(.title.bold().monospaced()).foregroundStyle(.cyan)
                }
                VStack {
                    Text("HIGH SCORE").font(.caption2).foregroundStyle(.secondary)
                    Text(String(format: "%06d", highScore))
                        .font(.title.bold().monospaced()).foregroundStyle(.green)
                }
            }
            Spacer()
            Button(action: restart) {
                Text("PLAY AGAIN")
                    .font(.title2.bold())
                    .frame(width: 240, height: 56)
                    .background(
                        LinearGradient(colors: [.yellow, .orange],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: .yellow.opacity(0.3), radius: 10)
            }
            .buttonStyle(ClickEffect())
        }
        .padding(40)
    }
}
