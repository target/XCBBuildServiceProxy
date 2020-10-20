workspace(name = "com_github_target_xcbbuildserviceproxy")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Toolchains

http_archive(
    name = "build_bazel_apple_support",
    sha256 = "36d60bce680446ab534b141c47f2aef6b9c598267ef3450b7d74b9d81e1fd6bd",
    url = "https://github.com/bazelbuild/apple_support/releases/download/0.9.0/apple_support.0.9.0.tar.gz",
)

http_archive(
    name = "build_bazel_rules_apple",
    sha256 = "55f4dc1c9bf21bb87442665f4618cff1f1343537a2bd89252078b987dcd9c382",
    url = "https://github.com/bazelbuild/rules_apple/releases/download/0.20.0/rules_apple.0.20.0.tar.gz",
)

http_archive(
    name = "build_bazel_rules_swift",
    sha256 = "d2f38c33dc82cf3160c59342203d31a030e53ebe8f4c7365add7a549223f9c62",
    url = "https://github.com/bazelbuild/rules_swift/releases/download/0.15.0/rules_swift.0.15.0.tar.gz",
)

load("@build_bazel_apple_support//lib:repositories.bzl", "apple_support_dependencies")

apple_support_dependencies()

load("@build_bazel_rules_apple//apple:repositories.bzl", "apple_rules_dependencies")

apple_rules_dependencies()

load("@build_bazel_rules_swift//swift:repositories.bzl", "swift_rules_dependencies")

swift_rules_dependencies()

load("@build_bazel_rules_swift//swift:extras.bzl", "swift_rules_extra_dependencies")

swift_rules_extra_dependencies()

# Project dependencies

load("@com_github_target_xcbbuildserviceproxy//:repositories.bzl", "xcbbuildserviceproxy_dependencies")

xcbbuildserviceproxy_dependencies()
