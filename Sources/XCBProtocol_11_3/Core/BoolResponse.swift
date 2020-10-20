import Foundation
import MessagePack
import XCBProtocol

public struct BoolResponse {
    public let value: Bool
    
    public init(_ value: Bool) {
        self.value = value
    }
}

// MARK: - ResponsePayloadConvertible

extension BoolResponse: ResponsePayloadConvertible {
    public func toResponsePayload() -> ResponsePayload { .bool(self) }
}

// MARK: - Decoding

extension BoolResponse: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 1 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.value = try args.parseBool(indexPath: indexPath + IndexPath(index: 0))
    }
}

// MARK: - Encoding

extension BoolResponse: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [.bool(value)]
    }
}
