load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "MessagePack",
    srcs = glob(["**/*.swift"]),
    module_name = "MessagePack",
    visibility = [
        "//Sources:__subpackages__",
        "//Tests:__subpackages__",
    ],
)
