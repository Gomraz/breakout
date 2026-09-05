 import SwiftUI

@main
struct BreakoutGameApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 800, height: 680)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
