"""Definitions for handling Bazel repositories used by the Swift rules."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# Make sure to update the versions used in the `Package.swift` file if you change them here

def xcbbuildserviceproxy_dependencies():
    """Fetches repositories that are dependencies of `XCBBuildServiceProxy`."""
    maybe(
        http_archive,
        build_file = "@com_github_target_xcbbuildserviceproxy//:external/com_github_apple_swift_log.BUILD",
        name = "com_github_apple_swift_log",
        sha256 = "de51662b35f47764b6e12e9f1d43e7de28f6dd64f05bc30a318cf978cf3bc473",
        strip_prefix = "swift-log-1.4.2",
        urls = [
            "https://github.com/apple/swift-log/archive/1.4.2.tar.gz",
        ],
    )

    maybe(
        http_archive,
        build_file = "@com_github_target_xcbbuildserviceproxy//:external/com_github_apple_swift_nio.BUILD",
        name = "com_github_apple_swift_nio",
        sha256 = "4a654952046a46ad8f09d359e6c02e7fa04ab09f492ae35f5d6d7c769f3f008a",
        strip_prefix = "swift-nio-2.33.0",
        urls = [
            "https://github.com/apple/swift-nio/archive/2.33.0.tar.gz",
        ],
    )
