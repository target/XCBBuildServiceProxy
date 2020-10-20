import Foundation
import MessagePack
import XCBProtocol

public struct BuildStartRequest {
    public let sessionHandle: String
    public let buildNumber: Int64
}

// MARK: - Decoding

extension BuildStartRequest: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 2 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.sessionHandle = try args.parseString(indexPath: indexPath + IndexPath(index: 0))
        self.buildNumber = try args.parseInt64(indexPath: indexPath + IndexPath(index: 1))
    }
}
