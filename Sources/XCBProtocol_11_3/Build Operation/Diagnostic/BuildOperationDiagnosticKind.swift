import Foundation
import MessagePack
import XCBProtocol

public enum BuildOperationDiagnosticKind: Int64 {
    case info
    case warning
    case error
}

// MARK: - Decoding

extension BuildOperationDiagnosticKind: CustomDecodableRPCPayload {
    public init(values: [MessagePackValue], indexPath: IndexPath) throws {
        let rawValue = try values.parseInt64(indexPath: indexPath)
        
        guard let parsed = Self(rawValue: rawValue) else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: Self.self)
        }
        
        self = parsed
    }
}

// MARK: - Encoding
