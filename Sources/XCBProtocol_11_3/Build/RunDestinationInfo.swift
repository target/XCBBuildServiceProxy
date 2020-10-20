import Foundation
import MessagePack
import XCBProtocol

public struct RunDestinationInfo {
    public let platform: BuildPlatform // e.g. "macosx"
    public let sdkVariant: SDKVariant //  e.g. "macosx10.14"
    public let modernPlatform: String // e.g. "macos". This is a made up name. I couldn't find the correct one in https://github.com/keith/Xcode.app-strings/blob/master/Xcode.app/Contents/SharedFrameworks/XCBuild.framework/Versions/A/PlugIns/XCBBuildService.bundle/Contents/Frameworks/XCBProtocol.framework/Versions/A/XCBProtocol.
    public let targetArchitecture: String // e.g. "x86_64", "arm64"
    public let supportedArchitectures: [String] // e.g. ["armv7s", "arm64"]
    public let disableOnlyActiveArch: Bool
}

// MARK: - Decoding

extension RunDestinationInfo: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 6 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.platform = try args.parseObject(indexPath: indexPath + IndexPath(index: 0))
        self.sdkVariant = try args.parseObject(indexPath: indexPath + IndexPath(index: 1))
        self.modernPlatform = try args.parseString(indexPath: indexPath + IndexPath(index: 2))
        self.targetArchitecture = try args.parseString(indexPath: indexPath + IndexPath(index: 3))
        self.supportedArchitectures = try args.parseStringArray(indexPath: indexPath + IndexPath(index: 4))
        self.disableOnlyActiveArch = try args.parseBool(indexPath: indexPath + IndexPath(index: 5))
    }
}
