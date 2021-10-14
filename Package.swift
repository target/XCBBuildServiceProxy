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
        .library(name: "XCBProtocol_13_0", targets: ["XCBProtocol_13_0"]),
        .library(name: "XCBBuildServiceProxy", targets: ["XCBBuildServiceProxy"]),
    ],
    dependencies: [
        // Make sure to update the versions used in the `repositories.bzl` file if you change them here
        .package(url: "https://github.com/apple/swift-log", .exact("1.4.2")),
        .package(url: "https://github.com/apple/swift-nio", .exact("2.30.0")),
    ],
    targets: [
        .target(
            name: "MessagePack",
            exclude: [
                "BUILD.bazel",
                "LICENSE",
                "README.md"
            ]
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
            ],
            exclude: [
                "BUILD.bazel"
            ]
        ),
        .target(
            name: "XCBProtocol_11_3",
            dependencies: [
                "MessagePack",
                "XCBProtocol",
            ],
            exclude: [
                "BUILD.bazel"
            ]
        ),
        .target(
            name: "XCBProtocol_11_4",
            dependencies: [
                "MessagePack",
                "XCBProtocol",
            ],
            exclude: [
                "BUILD.bazel"
            ]
        ),
        .target(
            name: "XCBProtocol_12_0",
            dependencies: [
                "MessagePack",
                "XCBProtocol",
            ],
            exclude: [
                "BUILD.bazel"
            ]
        ),
        .target(
            name: "XCBProtocol_12_5",
            dependencies: [
                "MessagePack",
                "XCBProtocol",
            ],
            exclude: [
                "BUILD.bazel"
            ]
        ),
        .target(
            name: "XCBProtocol_13_0",
            dependencies: [
                "MessagePack",
                "XCBProtocol",
            ],
            exclude: [
                "BUILD.bazel"
            ]
        ),
        .target(
            name: "XCBBuildServiceProxy",
            dependencies: [
                "Logging",
                "NIO",
                "XCBProtocol",
            ],
            exclude: [
                "BUILD.bazel"
            ]
        ),
    ]
)
