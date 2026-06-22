// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "RouteBar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "RouteBarCore",
            targets: ["RouteBarCore"]
        ),
        .executable(
            name: "RouteBar",
            targets: ["RouteBarApp"]
        ),
        .executable(
            name: "RouteBarCoreChecks",
            targets: ["RouteBarCoreChecks"]
        )
    ],
    targets: [
        .target(name: "RouteBarCore"),
        .executableTarget(
            name: "RouteBarApp",
            dependencies: ["RouteBarCore"],
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "RouteBarCoreChecks",
            dependencies: ["RouteBarCore"],
            path: "Tools/CoreChecks"
        )
    ]
)
