# How to support new version of Xcode

When Xcode updates, it might change the format of its messages to XCBBuildService. This requires changes to the proxy to support.

There are two ways to debug: reading logs, and debugging using Xcode. Both have their own benefits and drawbacks, and it's likely you'll lean on both when working to update the library.

## Logs

This project makes thorough use of [swift-logging](https://github.com/apple/swift-log), so to see what's wrong, look in the logs!

You can start recording logs by executing `write_shim.sh`. You'll need your built `BazelXCBBuildService` and the path to where Xcode is expecting `XCBBuildService`. You also pass in the Xcode version, so your logs will be split based on the Xcode version.

The `XCBBuildService` lives here: `$(XCODE_DIR)/Contents/SharedFrameworks/XCBuild.framework/PlugIns/XCBBuildService.bundle/Contents/MacOS/XCBBuildService`

`write_shim.sh` will create a fake `XCBBuildService` that simply calls the `BazelXCBBuildService` while redirecting `STDERR` to a log file in `/tmp/Bazel-trace/`.

### Prepping for a new version of Xcode:

* Create a new module inside `/Sources` following the established pattern. (e.g. `XCBProtocol_14_0`).
* You'll notice we make use of symlinks to old versions of the files. Rather than copying every single file into the new `XCBProtocol` version, only copy files you need to change. For the rest, create a symlink to the previous version of the file (which may be a symlink itself). You'll see lots of symlinks pointing all the way back to the Xcode 11.4 versions!
* Update `Examples/BazelXCBBuildService/BUILD.bazel` and `Examples/BazelXCBBuildService/Packge.swift` to point at that new module.
* Update `Examples/BazelXCBBuildService/Sources/RequestHandler.swift` to assign the appropriate `RequestPayload` and `ResponsePayload` types to the `BazelXCBBuildServiceRequestPayload` and `BazelXCBBuildServiceResponsePayload` typealiases.
* Rename the original `XCBBuildService` in the Xcode bundle to `XCBBuildService.original`, just in case you want it again.

### Development loop:

* Rebuild with `bazel build BazelXCBBuildService`.
* Move it into the proper folder: `My-New-Xcode.app/Contents/SharedFrameworks/XCBuild.framework/PlugIns/XCBBuildService.bundle/Contents/MacOS/BazelXCBBuildService`.
* Run `write_shim.sh` to set up logging into `/tmp/Bazel-trace/`.
* Restart Xcode.
* Do some actions in Xcode, then view the logs. Are there any errors?
* Make a change in the project fixing an error or adding extra logs you deem necessary.
* Repeat as necessary.

## Xcode Debugger

To debug `BazelXCBBuildService` while it is being used by Xcode, you will need two versions of Xcode. (e.g. 12.5.0 and 13.0.0)

1. Main version: The version required to build the app.
1. Debugging version: A different version that can build and attach to `BazelXCBBuildService`. (It can be a newer or older version than the "main" version of Xcode).

To set up `BazelXCBBuildService` for debugging:

1. Remove `BazelXCBBuildService` from the "debugging" Xcode if it is installed. In the "debugging" Xcode, we want to use the official XCBBuildService, not our custom one.
	1. To see if it is installed, open this folder inside Xcode:
		```sh
		open /Applications/Xcode-<debugging-version-number>.app/Contents/SharedFrameworks/XCBuild.framework/PlugIns/XCBBuildService.bundle/Contents/MacOS/
		```
	1. If there are three files (`XCBBuildService.original`, `XCBBuildService`, and `BazelXCBBuildService`), `BazelXCBBuildService` is installed in that version of Xcode. To uninstall it, delete `XCBBuildService` and `BazelXCBBuildService`, and rename `XCBBuildService.original` to `XCBBuildService`.
1. Open `tools/BazelXCBBuildService` in the "debugging" Xcode and build a debug version of BazelXCBBuildService.
1. Copy the built, debug version of `BazelXCBBuildService` from the DerivedData folder into the "main" version of Xcode:
	```sh
	FOLDER=$(ls ~/Library/Developer/Xcode/DerivedData | grep BazelXCBBuildService)
	cp ~/Library/Developer/Xcode/DerivedData/$FOLDER/Build/Products/Debug/BazelXCBBuildService \
	/Applications/Xcode-<main-version>.app/Contents/SharedFrameworks/XCBuild.framework/PlugIns/XCBBuildService.bundle/Contents/MacOS/
	```
1. Prepare the debugger to attach to the service:
	1. Open the scheme for this build, and navigate to the "Run" section on the left-hand sidebar
	1. In the "Info" tab, for the "Launch" option, select "Wait for the executable to be launched"
1. Set some breakpoints if desired
1. Build and run as normal, Xcode will wait for the binary to be launched and automatically attache its debugger
1. Start the "main" Xcode (Note: it may freeze if breakpoints are hit in `BazelXCBBuildService`)
1. Check that the "debugging" Xcode has attached to `BazelXCBBuildService`
1. Perform build actions in the "main" Xcode and debug `BazelXCBBuildService` using the "debugging" Xcode 🎉
