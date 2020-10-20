import Foundation
import MessagePack
import XCBProtocol

public struct TransferSessionPIFRequest {
    public let sessionHandle: String
    public let workspaceSignature: String
}

// MARK: - Decoding

extension TransferSessionPIFRequest: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 2 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.sessionHandle = try args.parseString(indexPath: indexPath + IndexPath(index: 0))
        self.workspaceSignature = try args.parseString(indexPath: indexPath + IndexPath(index: 1))
    }
}
