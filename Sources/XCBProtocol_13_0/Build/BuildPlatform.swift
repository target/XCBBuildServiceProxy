import Foundation
import MessagePack
import XCBProtocol

public enum BuildPlatform: String, Decodable {
    case macosx
    case iphoneos
    case iphonesimulator
    case watchos
    case watchsimulator
    case appletvos
    case appletvsimulator
}

// MARK: - Decoding

extension BuildPlatform: CustomDecodableRPCPayload {
    public init(values: [MessagePackValue], indexPath: IndexPath) throws {
        guard let parsed = Self(rawValue: try values.parseString(indexPath: indexPath)) else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: Self.self)
        }

        self = parsed
    }
}

extension BuildPlatform: CustomStringConvertible {
    public var description: String { rawValue }
}

// MARK: - Encoding

extension BuildPlatform: CustomEncodableRPCPayload {
    public func encode() -> MessagePackValue {
        return .string(rawValue)
    }
}
