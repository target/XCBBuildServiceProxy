// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "BazelProgressXCBBuildService",
    platforms: [.macOS(.v10_14)],
    products: [
        .executable(name: "BazelProgressXCBBuildService", targets: ["BazelProgressXCBBuildService"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.2"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.33.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.9.0"),
        // XCBBuildServiceProxy lives up two levels from here
        .package(path: "../../"),
        .package(path: "../BazelXCBBuildService/"),
    ],
    targets: [
        .target(
            name: "BazelProgressXCBBuildService",
            dependencies: [
                "src_main_java_com_google_devtools_build_lib_buildeventstream_proto_build_event_stream_proto",
                "Logging",
                "NIO",
                "SwiftProtobuf",
                "XCBBuildServiceProxy",
                "XCBProtocol",
                "XCBProtocol_13_0",
            ],
            path: "Sources"
        ),
    ]
)
