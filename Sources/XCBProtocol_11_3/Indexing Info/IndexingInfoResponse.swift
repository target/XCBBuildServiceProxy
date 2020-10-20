import Foundation
import MessagePack
import XCBProtocol

public struct IndexingInfoResponse {
    public let targetGUID: String // Called `targetID` by Xcode
    public let data: Data
    
    public init(targetGUID: String, data: Data) {
        self.targetGUID = targetGUID
        self.data = data
    }
}

// MARK: - ResponsePayloadConvertible

extension IndexingInfoResponse: ResponsePayloadConvertible {
    public func toResponsePayload() -> ResponsePayload { .indexingInfo(self) }
}

// MARK: - Decoding

extension IndexingInfoResponse: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 2 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.targetGUID = try args.parseString(indexPath: indexPath + IndexPath(index: 0))
        self.data = try args.parseBinary(indexPath: indexPath + IndexPath(index: 1))
    }
}

// MARK: - Encoding

extension IndexingInfoResponse: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [
            .string(targetGUID),
            .binary(data),
        ]
    }
}
