import Foundation
import MessagePack
import XCBProtocol

public struct IndexingInfoRequest {
    public let sessionHandle: String
    public let responseChannel: UInt64
    public let buildRequest: BuildRequest // Called `request` by Xcode
    public let targetGUID: String // Called `targetID` by Xcode
    public let unknown1: MessagePackValue
    public let unknown2: Bool
}

// MARK: - Decoding

extension IndexingInfoRequest: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 6 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.sessionHandle = try args.parseString(indexPath: indexPath + IndexPath(index: 0))
        self.responseChannel = try args.parseUInt64(indexPath: indexPath + IndexPath(index: 1))
        self.buildRequest = try args.parseObject(indexPath: indexPath + IndexPath(index: 2))
        self.targetGUID = try args.parseString(indexPath: indexPath + IndexPath(index: 3))
        self.unknown1 = try args.parseUnknown(indexPath: indexPath + IndexPath(index: 4))
        self.unknown2 = try args.parseBool(indexPath: indexPath + IndexPath(index: 5))
    }
}
