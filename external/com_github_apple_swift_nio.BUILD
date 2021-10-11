load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load("@rules_cc//cc:defs.bzl", "objc_library")

swift_library(
    name = "NIO",
    srcs = glob(["Sources/NIO/**/*.swift"]),
    visibility = ["//visibility:public"],
    deps = [
        ":CNIOAtomics",
        ":CNIODarwin",
        ":CNIOLinux",
        ":NIOConcurrencyHelpers",
        ":NIOCore",
        ":NIOEmbedded",
        ":NIOPosix",
    ],
)

swift_library(
    name = "NIOEmbedded",
    srcs = glob(["Sources/NIOEmbedded/**/*.swift"]),
    deps = [
      ":_NIODataStructures",
      ":NIOCore",
    ],
)

swift_library(
    name = "_NIODataStructures",
    srcs = glob(["Sources/_NIODataStructures/**/*.swift"]),
    deps = [],
)

swift_library(
    name = "NIOPosix",
    srcs = glob(["Sources/NIOPosix/**/*.swift"]),
    deps = [
      ":NIOCore",
    ],
)

swift_library(
    name = "NIOCore",
    srcs = glob(["Sources/NIOCore/**/*.swift"]),
    deps = [
      ":NIOConcurrencyHelpers",
    ],
)

swift_library(
    name = "NIOConcurrencyHelpers",
    srcs = glob(["Sources/NIOConcurrencyHelpers/**/*.swift"]),
    deps = [
        ":CNIOAtomics",
    ],
)

objc_library(
    name = "CNIOAtomics",
    module_name = "CNIOAtomics",
    srcs = glob([
        "Sources/CNIOAtomics/src/**/*.c",
        "Sources/CNIOAtomics/src/**/*.h",
    ]),
    hdrs = glob([
        "Sources/CNIOAtomics/include/**/*.h",
    ]),
    includes = ["Sources/CNIOAtomics/include"],
)

objc_library(
    name = "CNIODarwin",
    module_name = "CNIODarwin",
    srcs = glob([
        "Sources/CNIODarwin/**/*.c",
    ]),
    hdrs = glob([
        "Sources/CNIODarwin/include/**/*.h",
    ]),
    includes = ["Sources/CNIODarwin/include"],
    defines = ["__APPLE_USE_RFC_3542"],
)

objc_library(
    name = "CNIOLinux",
    module_name = "CNIOLinux",
    srcs = glob([
        "Sources/CNIOLinux/**/*.c",
    ]),
    hdrs = glob([
        "Sources/CNIOLinux/include/**/*.h",
    ]),
    includes = ["Sources/CNIOLinux/include"],
)
