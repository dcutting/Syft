// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Syft",
    targets: [
        .target(
            name: "Sample",
            dependencies: ["Syft"]),
        .target(
            name: "Syft"),
        .testTarget(
            name: "SyftTests",
            dependencies: ["Syft"])
    ]
)
