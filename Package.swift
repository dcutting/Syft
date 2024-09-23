// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "Syft",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "Syft", targets: ["Syft"])
    ],
    targets: [
        .target(
            name: "Syft"),
        .testTarget(
            name: "SyftTests",
            dependencies: ["Syft"])
    ]
)
