load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "MessagePackTests.library",
    srcs = glob(["**/*.swift"]),
    module_name = "MessagePackTests",
    deps = ["//Sources/MessagePack"],
)

macos_unit_test(
    name = "MessagePackTests",
    minimum_os_version = "10.14",
    deps = [":MessagePackTests.library"],
)
