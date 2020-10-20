import Foundation
import MessagePack
import XCBProtocol

public struct PingResponse {
    public init() {}
}

// MARK: - ResponsePayloadConvertible

extension PingResponse: ResponsePayloadConvertible {
    public func toResponsePayload() -> ResponsePayload { .ping(self) }
}

// MARK: - Decoding

extension PingResponse: CustomDecodableRPCPayload {
    public init(values: [MessagePackValue], indexPath: IndexPath) {}
}

// MARK: - Encoding

extension PingResponse: CustomEncodableRPCPayload {
    public func encode() -> MessagePackValue {
        return .nil
    }
}
