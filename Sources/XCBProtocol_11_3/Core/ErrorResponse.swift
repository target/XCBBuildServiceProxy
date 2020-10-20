import Foundation
import MessagePack
import XCBProtocol

public struct ErrorResponse {
    public let message: String
    
    public init(_ message: String) {
        self.message = message
    }
}

// MARK: - ResponsePayloadConvertible

extension ErrorResponse: ResponsePayloadConvertible {
    public func toResponsePayload() -> ResponsePayload { .error(self) }
}

// MARK: - Decoding

extension ErrorResponse: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 1 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.message = try args.parseString(indexPath: indexPath + IndexPath(index: 0))
    }
}

// MARK: - Encoding

extension ErrorResponse: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [.string(message)]
    }
}
