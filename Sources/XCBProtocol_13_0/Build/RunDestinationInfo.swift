import Foundation
import MessagePack
import XCBProtocol

public struct RunDestinationInfo: Decodable {
    public let platform: BuildPlatform // e.g. "macosx"
    public let sdk: String //  e.g. "macosx10.14"
    public let sdkVariant: String  //  e.g. "macos" or "iphonesimulator"
    public let targetArchitecture: String // e.g. "x86_64", "arm64"
    public let supportedArchitectures: [String] // e.g. ["armv7s", "arm64"]
    public let disableOnlyActiveArch: Bool
}
