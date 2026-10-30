// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Remend",
    platforms: [.iOS(.v15), .macOS(.v12), .tvOS(.v15), .watchOS(.v8)],
    products: [.library(name: "Remend", targets: ["Remend"])],
    targets: [
        .target(name: "Remend"),
        .testTarget(name: "RemendTests", dependencies: ["Remend"], resources: [.copy("Fixtures")]),
    ],
    swiftLanguageModes: [.v6]
)
