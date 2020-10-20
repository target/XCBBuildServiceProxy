import Foundation
import MessagePack
import XCBProtocol

public struct BuildOperationTargetEnded {
    public let targetID: Int64
    
    public init(targetID: Int64) {
        self.targetID = targetID
    }
}

// MARK: - ResponsePayloadConvertible

extension BuildOperationTargetEnded: ResponsePayloadConvertible {
    public func toResponsePayload() -> ResponsePayload { .buildOperationTargetEnded(self) }
}

// MARK: - Decoding

extension BuildOperationTargetEnded: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 1 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.targetID = try args.parseInt64(indexPath: indexPath + IndexPath(index: 0))
    }
}

// MARK: - Encoding

extension BuildOperationTargetEnded: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [.int64(targetID)]
    }
}
