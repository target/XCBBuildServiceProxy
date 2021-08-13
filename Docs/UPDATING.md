# How to support new version of Xcode

When Xcode updates, it might change the format of its messages to XCBBuildService.

This project makes thorough use of [swift-logging](https://github.com/apple/swift-log), so to see what's wrong, look in the logs!

You can start recording logs by executing `write_shim.sh`. You'll need your built `BazelXCBBuildService` and the path to where Xcode is expecting `XCBBuildService`. You also pass in the Xcode version, so your logs will be split based on the Xcode version.

The `XCBBuildService` lives here: `$(XCODE_DIR)/Contents/SharedFrameworks/XCBuild.framework/PlugIns/XCBBuildService.bundle/Contents/MacOS/XCBBuildService`

`write_shim.sh` will create a fake `XCBBuildService` that simply calls the `BazelXCBBuildService` while redirecting `STDERR` to a log file in `/tmp/Bazel-trace/`.

### Prepping for a new version of Xcode:
* Create a new module inside `/Sources` following the established pattern. (e.g. `XCBProtocol_14_0`)
* Update `Examples/BazelXCBBuildService/BUILD.bazel` and `Examples/BazelXCBBuildService/Packge.swift` to point at that new module
* Update `Examples/BazelXCBBuildService/Sources/RequestHandler.swift` to assign the appropriate `RequestPayload` and `ResponsePayload` types to the `BazelXCBBuildServiceRequestPayload` and `BazelXCBBuildServiceResponsePayload` typealiases.
* Rename the original `XCBBuildService` in the Xcode bundle to `XCBBuildService.original`, just in case you want it again.

### Development loop:
* Rebuild: `bazel build BazelXCBBuildService`
* Move it into the proper folder: `My-New-Xcode.app/Contents/SharedFrameworks/XCBuild.framework/PlugIns/XCBBuildService.bundle/Contents/MacOS/BazelXCBBuildService`
* Run `write_shim.sh` to set up logging into `/tmp/Bazel-trace/`
* Restart Xcode
* Do some actions in Xcode, then view the logs, are there any errors?
* Make a change in the project fixing an error or adding extra logs you deem necessary.
* Repeat

