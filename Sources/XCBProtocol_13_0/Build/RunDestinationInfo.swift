import Foundation
import MessagePack
import XCBProtocol

public struct RunDestinationInfo: Decodable {
    public let platform: BuildPlatform // e.g. "macosx"
    public let sdk: String
    public let sdkVariant: String //  e.g. "macosx10.14"
//    public let modernPlatform: String // e.g. "macos". This is a made up name. I couldn't find the correct one in https://github.com/keith/Xcode.app-strings/blob/master/Xcode.app/Contents/SharedFrameworks/XCBuild.framework/Versions/A/PlugIns/XCBBuildService.bundle/Contents/Frameworks/XCBProtocol.framework/Versions/A/XCBProtocol.
    public let targetArchitecture: String // e.g. "x86_64", "arm64"
    public let supportedArchitectures: [String] // e.g. ["armv7s", "arm64"]
    public let disableOnlyActiveArch: Bool
}
