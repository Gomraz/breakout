// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BreakoutGame",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "BreakoutGame",
            path: "BreakoutGame"
        )
    ]
)
