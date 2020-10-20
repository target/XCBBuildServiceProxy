import Foundation
import MessagePack
import XCBProtocol

public struct BuildParameters {
    public let action: String // e.g. "build", "clean"
    public let configuration: String // e.g. "Debug", "Release"
    public let activeRunDestination: RunDestinationInfo
    public let activeArchitecture: String // e.g. "x86_64", "arm64"
    public let arenaInfo: ArenaInfo
    public let overrides: SettingsOverrides
    public let xbsParameters: MessagePackValue
}

// MARK: - Decoding

extension BuildParameters: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 7 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.action = try args.parseString(indexPath: indexPath + IndexPath(index: 0))
        self.configuration = try args.parseString(indexPath: indexPath + IndexPath(index: 1))
        self.activeRunDestination = try args.parseObject(indexPath: indexPath + IndexPath(index: 2))
        self.activeArchitecture = try args.parseString(indexPath: indexPath + IndexPath(index: 3))
        self.arenaInfo = try args.parseObject(indexPath: indexPath + IndexPath(index: 4))
        self.overrides = try args.parseObject(indexPath: IndexPath(index: 5))
        self.xbsParameters = try args.parseUnknown(indexPath: IndexPath(index: 6))
    }
}
