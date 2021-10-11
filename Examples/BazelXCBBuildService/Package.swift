// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "BazelXCBBuildService",
    platforms: [.macOS(.v10_14)],
    products: [
        .executable(name: "BazelXCBBuildService", targets: ["BazelXCBBuildService"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.17.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.9.0"),
        // XCBBuildServiceProxy lives up two levels from here
        .package(path: "../../"),
    ],
    targets: [
        .target(
            name: "BazelXCBBuildService",
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
        .target(
            name: "src_main_java_com_google_devtools_build_lib_buildeventstream_proto_build_event_stream_proto",
            dependencies: [
                "src_main_protobuf_command_line_proto",
                "src_main_protobuf_failure_details_proto",
                "src_main_protobuf_invocation_policy_proto",
                "SwiftProtobuf",
            ],
            path: "",
            sources: ["BEP/src/main/java/com/google/devtools/build/lib/buildeventstream/proto/build_event_stream.pb.swift"]
        ),
        .target(
            name: "src_main_protobuf_command_line_proto",
            dependencies: [
                "src_main_protobuf_option_filters_proto",
                "SwiftProtobuf",
            ],
            path: "",
            sources: ["BEP/src/main/protobuf/command_line.pb.swift"]
        ),
        .target(
            name: "src_main_protobuf_option_filters_proto",
            dependencies: [
                "SwiftProtobuf",
            ],
            path: "",
            sources: ["BEP/src/main/protobuf/option_filters.pb.swift"]
        ),
        .target(
            name: "src_main_protobuf_failure_details_proto",
            dependencies: [
                "SwiftProtobuf",
            ],
            path: "",
            sources: ["BEP/src/main/protobuf/failure_details.pb.swift"]
        ),
        .target(
            name: "src_main_protobuf_invocation_policy_proto",
            dependencies: [
                "SwiftProtobuf",
            ],
            path: "",
            sources: ["BEP/src/main/protobuf/invocation_policy.pb.swift"]
        ),
    ]
)
