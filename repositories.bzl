"""Definitions for handling Bazel repositories used by the Swift rules."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _maybe(repo_rule, name, **kwargs):
    """Executes the given repository rule if it hasn't been executed already.

    Args:
      repo_rule: The repository rule to be executed (e.g., `http_archive`.)
      name: The name of the repository to be defined by the rule.
      **kwargs: Additional arguments passed directly to the repository rule.
    """
    if not native.existing_rule(name):
        repo_rule(name = name, **kwargs)

def xcbbuildserviceproxy_dependencies():
    """Fetches repositories that are dependencies of `XCBBuildServiceProxy`."""
    _maybe(
        http_archive,
        build_file = "@com_github_target_xcbbuildserviceproxy//:external/com_github_apple_swift_log.BUILD",
        name = "com_github_apple_swift_log",
        sha256 = "88f40a82f2856cdafe20d09e0f6f5a6468abb21c5d6a8490c90954c57881bc18",
        strip_prefix = "swift-log-1.2.0",
        urls = [
            "https://github.com/apple/swift-log/archive/1.2.0.tar.gz",
        ],
    )

    _maybe(
        http_archive,
        build_file = "@com_github_target_xcbbuildserviceproxy//:external/com_github_apple_swift_nio.BUILD",
        name = "com_github_apple_swift_nio",
        sha256 = "b867079d9bfdc61a02647ecdc3587576b0e88f8f2d47b28883d6dbf2e549a7af",
        strip_prefix = "swift-nio-2.17.0",
        urls = [
            "https://github.com/apple/swift-nio/archive/2.17.0.tar.gz",
        ],
    )
