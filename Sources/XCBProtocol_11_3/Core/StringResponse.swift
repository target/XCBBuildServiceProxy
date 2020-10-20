import Foundation
import MessagePack
import XCBProtocol

public struct StringResponse {
    public let value: String
    
    public init(_ value: String) {
        self.value = value
    }
}

// MARK: - ResponsePayloadConvertible

extension StringResponse: ResponsePayloadConvertible {
    public func toResponsePayload() -> ResponsePayload { .string(self) }
}

// MARK: - Decoding

extension StringResponse: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 1 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.value = try args.parseString(indexPath: indexPath + IndexPath(index: 0))
    }
}

// MARK: - Encoding

extension StringResponse: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [.string(value)]
    }
}
