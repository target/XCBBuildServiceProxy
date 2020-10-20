import Foundation
import MessagePack
import XCBProtocol

public struct CreateBuildRequest {
    public let sessionHandle: String
    public let responseChannel: UInt64
    public let buildRequest: BuildRequest // Called `request` by Xcode
}

// MARK: - Decoding

extension CreateBuildRequest: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 3 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.sessionHandle = try args.parseString(indexPath: indexPath + IndexPath(index: 0))
        self.responseChannel = try args.parseUInt64(indexPath: indexPath + IndexPath(index: 1))
        self.buildRequest = try args.parseObject(indexPath: indexPath + IndexPath(index: 2))
    }
}
