import Foundation
import MessagePack
import XCBProtocol

public enum SchemeCommand: Int64 {
    case launch
    case test
    case profile
    case archive
}

// MARK: - Decoding

extension SchemeCommand: CustomDecodableRPCPayload {
    public init(values: [MessagePackValue], indexPath: IndexPath) throws {
        let rawValue = try values.parseInt64(indexPath: indexPath)
        
        guard let parsed = Self(rawValue: rawValue) else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: Self.self)
        }
        
        self = parsed
    }
}
