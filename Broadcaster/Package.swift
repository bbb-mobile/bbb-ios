// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Broadcaster",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "Broadcaster",
            targets: ["Broadcaster"]),
    ],
    dependencies: [
        .package(url: "https://github.com/stasel/WebRTC", .upToNextMajor(from: "96.0.0"))
    ],
    targets: [
        .target(
            name: "Broadcaster",
            dependencies: ["WebRTC"]),
        .testTarget(
            name: "BroadcasterTests",
            dependencies: ["Broadcaster"]),
    ]
)
