"""Definitions for handling Bazel repositories used by the Swift rules."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def xcbbuildserviceproxy_dependencies():
    """Fetches repositories that are dependencies of `XCBBuildServiceProxy`."""
    maybe(
        http_archive,
        build_file = "@com_github_target_xcbbuildserviceproxy//:external/com_github_apple_swift_log.BUILD",
        name = "com_github_apple_swift_log",
        sha256 = "88f40a82f2856cdafe20d09e0f6f5a6468abb21c5d6a8490c90954c57881bc18",
        strip_prefix = "swift-log-1.2.0",
        urls = [
            "https://github.com/apple/swift-log/archive/1.2.0.tar.gz",
        ],
    )

    maybe(
        http_archive,
        build_file = "@com_github_target_xcbbuildserviceproxy//:external/com_github_apple_swift_nio.BUILD",
        name = "com_github_apple_swift_nio",
        sha256 = "b867079d9bfdc61a02647ecdc3587576b0e88f8f2d47b28883d6dbf2e549a7af",
        strip_prefix = "swift-nio-2.17.0",
        urls = [
            "https://github.com/apple/swift-nio/archive/2.17.0.tar.gz",
        ],
    )
