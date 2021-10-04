import Foundation
import MessagePack
import XCBProtocol

// Probably named wrong
public enum BuildOperationDiagnosticLocation {
    case alternativeMessage(String) // Might be named wrong. Always empty so far.
    case locationContext(file: String, line: Int64, column: Int64)
    case sourceRanges([String])
}

// MARK: - Decoding

extension BuildOperationDiagnosticLocation: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 2 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        let rawValue = try args.parseInt64(indexPath: indexPath + IndexPath(index: 0))
        
        switch rawValue {
        case 0:
            self = .alternativeMessage(try args.parseString(indexPath: indexPath + IndexPath(index: 1)))
            
        case 1:
            let locationArgs = try args.parseArray(indexPath: indexPath + IndexPath(index: 1))
            
            self = .locationContext(
                file: try locationArgs.parseString(indexPath: indexPath + IndexPath(indexes: [1, 0])),
                line: try locationArgs.parseInt64(indexPath: indexPath + IndexPath(indexes: [1, 1])),
                column: try locationArgs.parseInt64(indexPath: indexPath + IndexPath(indexes: [1, 2]))
            )
            
        case 2:
            let sourceRangeArgs = try args.parseArray(indexPath: indexPath + IndexPath(index: 1))
            self = .sourceRanges(try targetArgs.parseStringArray(indexPath: indexPath + IndexPath(indexes: [1, 0])))
            
        default:
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath + IndexPath(index: 0), expectedType: Self.self)
        }
    }
}

// MARK: - Encoding

extension BuildOperationDiagnosticLocation: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        switch self {
        case let .alternativeMessage(message):
            return [
                .int64(0),
                .string(message),
            ]
            
        case let .locationContext(file, line, column):
            return [
                .int64(1),
                .array([
                    .string(file),
                    .int64(line),
                    .int64(column),
                ]),
            ]
            
        case let .sourceRanges(names):
            return [
                .array(names.map { .string($0) })
            ]
        }
    }
}
