// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "SwiftyFormat",
    platforms: [
        .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v2)
    ],
    products: [
        .library(name: "SwiftyFormat", targets: ["SwiftyFormat"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0")
    ],
    targets: [
        .target(name: "SwiftyFormat", dependencies: [], path: "Source"),
        .testTarget(name: "SwiftyFormatTests", dependencies: ["SwiftyFormat", "Nimble"]),
    ],
    swiftLanguageVersions: [.v5]
)
