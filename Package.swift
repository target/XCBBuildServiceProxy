// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "BazelXCBBuildServiceProxy",
    platforms: [.macOS(.v10_14)],
    products: [
        .library(name: "XCBProtocol", targets: ["XCBProtocol"]),
        .library(name: "XCBProtocol_11_3", targets: ["XCBProtocol_11_3"]),
        .library(name: "XCBProtocol_11_4", targets: ["XCBProtocol_11_4"]),
        .library(name: "XCBProtocol_12_0", targets: ["XCBProtocol_12_0"]),
        .library(name: "XCBProtocol_12_5", targets: ["XCBProtocol_12_5"]),
        .library(name: "XCBBuildServiceProxy", targets: ["XCBBuildServiceProxy"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.17.0"),
    ],
    targets: [
        .target(
            name: "MessagePack"
        ),
        .testTarget(
            name: "MessagePackTests",
            dependencies: ["MessagePack"]
        ),
        .target(
            name: "XCBProtocol",
            dependencies: [
                "Logging",
                "MessagePack",
                "NIO",
            ]
        ),
        .target(
            name: "XCBProtocol_11_3",
            dependencies: [
                "MessagePack",
                "XCBProtocol",
            ]
        ),
        .target(
            name: "XCBProtocol_11_4",
            dependencies: [
                "MessagePack",
                "XCBProtocol",
            ]
        ),
        .target(
            name: "XCBProtocol_12_0",
            dependencies: [
                "MessagePack",
                "XCBProtocol",
            ]
        ),
        .target(
            name: "XCBProtocol_12_5",
            dependencies: [
                "MessagePack",
                "XCBProtocol",
            ],
            exclude: ["BUILD.bazel"]
        ),
        .target(
            name: "XCBBuildServiceProxy",
            dependencies: [
                "Logging",
                "NIO",
                "XCBProtocol",
            ]
        ),
    ]
)
