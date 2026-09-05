import SwiftUI

struct MenuView: View {
    var startGame: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Title with glow
            Text("BREAKOUT")
                .font(.system(size: 80, weight: .bold, design: .monospaced))
                .foregroundStyle(
                    LinearGradient(colors: [.cyan, .blue, .purple],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .shadow(color: .cyan.opacity(0.5), radius: 20, x: 0, y: 0)
                .shadow(color: .purple.opacity(0.3), radius: 40, x: 0, y: 0)

            Text("A macOS Classic")
                .font(.title2)
                .foregroundStyle(.secondary)
                .opacity(0.7)

            Spacer()

            Button(action: startGame) {
                Text("START GAME")
                    .font(.title2.bold())
                    .frame(width: 240, height: 56)
                    .background(
                        LinearGradient(colors: [.cyan, .blue],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: .cyan.opacity(0.4), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(ClickEffect())

            VStack(spacing: 8) {
                Text("Move: Mouse drag")
                Text("Launch: Space / Click")
                Text("Laser: Hold / Long press")
                Text("Pause: ⌘P")
            }
            .font(.caption)
            .foregroundStyle(.secondary.opacity(0.6))

            Spacer()
        }
        .padding(40)
    }
}

struct ClickEffect: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
