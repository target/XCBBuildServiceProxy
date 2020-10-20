import Foundation
import MessagePack

// swiftformat:disable braces
// swiftlint:disable opening_brace

public protocol RequestPayload: CustomDecodableRPCPayload {
    static func unknownRequest(values: [MessagePackValue]) -> Self
    
    /// - Returns: the Xcode path in the `CREATE_SESSION` message, or `nil` if it's another message.
    var createSessionXcodePath: String? { get }
}

public protocol ResponsePayload: CustomDecodableRPCPayload, EncodableRPCPayload {
    static func unknownResponse(values: [MessagePackValue]) -> Self
    static func errorResponse(_ message: String) -> Self
}

public protocol ResponsePayloadConvertible {
    associatedtype Payload: ResponsePayload
    
    func toResponsePayload() -> Payload
}

extension RPCResponse {
    public init<PayloadConvertible>(channel: UInt64, payloadConvertible: PayloadConvertible) where
        PayloadConvertible: ResponsePayloadConvertible,
        PayloadConvertible.Payload == Payload
    {
        self.init(channel: channel, payload: payloadConvertible.toResponsePayload())
    }
}

// MARK: - Encoding/Decoding

// TODO: Replace with Decodable
public protocol DecodableRPCPayload {
    init(args: [MessagePackValue], indexPath: IndexPath) throws
}

// TODO: Replace with Decodable
public protocol CustomDecodableRPCPayload {
    init(values: [MessagePackValue], indexPath: IndexPath) throws
}

// TODO: Replace with Encodable
public protocol EncodableRPCPayload: CustomEncodableRPCPayload {
    func encode() -> [MessagePackValue]
}

public protocol CustomEncodableRPCPayload {
    func encode() -> MessagePackValue
}

public extension EncodableRPCPayload {
    func encode() -> MessagePackValue {
        return .array(encode())
    }
}

public enum RPCPayloadDecodingError: Error {
    case invalidCount(_ count: Int, indexPath: IndexPath)
    case indexOutOfBounds(indexPath: IndexPath)
    case incorrectValueType(indexPath: IndexPath, expectedType: Any.Type)
    case missingValue(indexPath: IndexPath)
}

// TODO: Replace with Codable
extension Array where Element == MessagePackValue {
    private func index(_ indexPath: IndexPath) throws -> Int {
        guard let index = indexPath.last else { preconditionFailure("Empty indexPath") }
        
        guard count > index else {
            throw RPCPayloadDecodingError.indexOutOfBounds(indexPath: indexPath)
        }
        
        return index
    }
    
    public func parseArray(indexPath: IndexPath) throws -> [MessagePackValue] {
        guard case let .array(value) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: [MessagePackValue].self)
        }
        return value
    }
    
    public func parseOptionalArray(indexPath: IndexPath) throws -> [MessagePackValue]? {
        if case .nil = self[try index(indexPath)] {
            return nil
        }
        
        guard case let .array(value) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: [MessagePackValue].self)
        }
        return value
    }
    
    public func parseBinary(indexPath: IndexPath) throws -> Data {
        guard case let .binary(value) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: Data.self)
        }
        return value
    }
    
    public func parseBool(indexPath: IndexPath) throws -> Bool {
        guard case let .bool(value) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: Bool.self)
        }
        return value
    }
    
    public func parseOptionalBool(indexPath: IndexPath) throws -> Bool? {
        if case .nil = self[try index(indexPath)] {
            return nil
        }
        
        guard case let .bool(value) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: Bool.self)
        }
        return value
    }
    
    public func parseDouble(indexPath: IndexPath) throws -> Double {
        guard case let .double(value) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: Double.self)
        }
        return value
    }
    
    public func parseInt8(indexPath: IndexPath) throws -> Int8 {
        guard case let .int8(value) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: Int8.self)
        }
        return value
    }
    
    public func parseInt16(indexPath: IndexPath) throws -> Int16 {
        guard case let .int16(value) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: Int16.self)
        }
        return value
    }
    
    public func parseInt32(indexPath: IndexPath) throws -> Int32 {
        guard case let .int32(value) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: Int32.self)
        }
        return value
    }
    
    public func parseInt64(indexPath: IndexPath) throws -> Int64 {
        guard case let .int64(value) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: Int64.self)
        }
        return value
    }
    
    public func parseOptionalInt64(indexPath: IndexPath) throws -> Int64? {
        if case .nil = self[try index(indexPath)] {
            return nil
        }
        
        guard case let .int64(value) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: Int64.self)
        }
        return value
    }
    
    public func parseMap(indexPath: IndexPath) throws -> [String: String] {
        guard case let .map(dict) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: [String: String].self)
        }
        
        return try dict.reduce(into: [:]) { dict, entry in
            guard case let .string(key) = entry.key, case let .string(value) = entry.value else {
                throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: [String: String].self)
            }
            dict[key] = value
        }
    }
    
    public func parseString(indexPath: IndexPath) throws -> String {
        guard case let .string(value) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: String.self)
        }
        return value
    }
    
    public func parseOptionalString(indexPath: IndexPath) throws -> String? {
        if case .nil = self[try index(indexPath)] {
            return nil
        }
        
        guard case let .string(value) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: String.self)
        }
        return value
    }
    
    public func parseStringArray(indexPath: IndexPath) throws -> [String] {
        let array = try parseArray(indexPath: indexPath)
        
        return try (0 ..< array.count).compactMap { index in
            if index < array.count, case .nil = array[index] { return nil }
            return try array.parseString(indexPath: indexPath.appending(index))
        }
    }
    
    public func parseUInt8(indexPath: IndexPath) throws -> UInt8 {
        guard case let .uint8(value) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: UInt8.self)
        }
        return value
    }
    
    public func parseUInt16(indexPath: IndexPath) throws -> UInt16 {
        guard case let .uint16(value) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: UInt16.self)
        }
        return value
    }
    
    public func parseUInt32(indexPath: IndexPath) throws -> UInt32 {
        guard case let .uint32(value) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: UInt32.self)
        }
        return value
    }
    
    public func parseUInt64(indexPath: IndexPath) throws -> UInt64 {
        guard case let .uint64(value) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: UInt64.self)
        }
        return value
    }
    
    public func parseOptionalUInt64(indexPath: IndexPath) throws -> UInt64? {
        if case .nil = self[try index(indexPath)] {
            return nil
        }
        
        guard case let .uint64(value) = self[try index(indexPath)] else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: UInt64.self)
        }
        return value
    }
    
    public func parseUnknown(indexPath: IndexPath) throws -> MessagePackValue {
        return self[try index(indexPath)]
    }
    
    public func parseObject<T: CustomDecodableRPCPayload>(type: T.Type = T.self, indexPath: IndexPath) throws -> T {
        return try T(values: self, indexPath: indexPath)
    }
    
    public func parseObject<T: DecodableRPCPayload>(type: T.Type = T.self, indexPath: IndexPath) throws -> T {
        guard let object = try parseOptionalObject(type: type, indexPath: indexPath) else {
            throw RPCPayloadDecodingError.missingValue(indexPath: indexPath)
        }
        
        return object
    }
    
    public func parseOptionalObject<T: DecodableRPCPayload>(type: T.Type = T.self, indexPath: IndexPath) throws -> T? {
        guard let args = try parseOptionalArray(indexPath: indexPath) else {
            return nil
        }
        
        return try T(args: args, indexPath: indexPath)
    }
}
