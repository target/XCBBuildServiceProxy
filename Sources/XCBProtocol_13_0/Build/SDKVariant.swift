import Foundation
import MessagePack
import XCBProtocol

public struct SDKVariant: Decodable {
    public let rawValue: String
}

// MARK: - Decoding

extension SDKVariant: CustomDecodableRPCPayload {
    public init(values: [MessagePackValue], indexPath: IndexPath) throws {
        self.rawValue = try values.parseString(indexPath: indexPath)
    }
}

extension SDKVariant: CustomStringConvertible {
    public var description: String { rawValue }
}

// MARK: - Encoding

extension SDKVariant: CustomEncodableRPCPayload {
    public func encode() -> MessagePackValue {
        return .string(rawValue)
    }
}
