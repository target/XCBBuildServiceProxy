import Foundation

public enum MessagePackValue: Equatable, Hashable {
    case `nil`
    case bool(Bool)
    case int8(Int8)
    case int16(Int16)
    case int32(Int32)
    case int64(Int64)
    case uint8(UInt8)
    case uint16(UInt16)
    case uint32(UInt32)
    case uint64(UInt64)
    case float(Float)
    case double(Double)
    case string(String)
    case binary(Data)
    case array([MessagePackValue])
    case map([MessagePackValue: MessagePackValue])
    case extended(Int8, Data)
}

extension MessagePackValue: CustomStringConvertible {
    public var description: String {
        switch self {
        case .nil:
            return "nil"
        case .bool(let value):
            return "bool(\(value))"
        case .int8(let value):
            return "int8(\(value))"
        case .int16(let value):
            return "int16(\(value))"
        case .int32(let value):
            return "int32(\(value))"
        case .int64(let value):
            return "int64(\(value))"
        case .uint8(let value):
            return "uint8(\(value))"
        case .uint16(let value):
            return "uint16(\(value))"
        case .uint32(let value):
            return "uint32(\(value))"
        case .uint64(let value):
            return "uint64(\(value))"
        case .float(let value):
            return "float(\(value))"
        case .double(let value):
            return "double(\(value))"
        case .string(let string):
            return "string(\(string))"
        case .binary(let data):
            return "data(\(data))"
        case .array(let array):
            return "array(\(array.description))"
        case .map(let dict):
            return "map(\(dict.description))"
        case .extended(let type, let data):
            return "extended(\(type), \(data))"
        }
    }
}
