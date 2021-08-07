import Foundation
import MessagePack
import XCBProtocol

public struct SettingsOverrides: Decodable {
    public let synthesized: [String: String] // e.g. ["TARGET_DEVICE_MODEL": "iPhone12,5", "TARGET_DEVICE_OS_VERSION": "13.3"]
    public let commandLine: [String: String]
    public let commandLineConfig: [String: String]
    public let environmentConfig: [String: String]
    public let toolchainOverride: String? // e.g. "org.swift.515120200323a"
}

// MARK: - Decoding

extension SettingsOverrides: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 5 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.synthesized = try args.parseMap(indexPath: indexPath + IndexPath(index: 0))
        self.commandLine = try args.parseMap(indexPath: indexPath + IndexPath(index: 1))
        self.commandLineConfig = try args.parseMap(indexPath: indexPath + IndexPath(index: 2))
        self.environmentConfig = try args.parseMap(indexPath: indexPath + IndexPath(index: 3))
        self.toolchainOverride = try args.parseOptionalString(indexPath: indexPath + IndexPath(index: 4))
    }
}
