import Foundation
import MessagePack
import XCBProtocol

public enum BuildOperationDiagnosticComponent {
    case task(taskID: Int64, targetID: Int64)
    case unknown(MessagePackValue) // Haven't seen it
    case global
}

// MARK: - Decoding

extension BuildOperationDiagnosticComponent: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 2 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        let rawValue = try args.parseInt64(indexPath: indexPath + IndexPath(index: 0))
        
        switch rawValue {
        case 0:
            let taskArgs = try args.parseArray(indexPath: indexPath + IndexPath(index: 1))
        
            self = .task(
                taskID: try taskArgs.parseInt64(indexPath: indexPath + IndexPath(indexes: [1, 0])),
                targetID: try taskArgs.parseInt64(indexPath: indexPath + IndexPath(indexes: [1, 1]))
            )
            
        case 1:
            self = .unknown(try args.parseUnknown(indexPath: indexPath + IndexPath(index: 1)))
            
        case 2:
            self = .global
            
        default:
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath + IndexPath(index: 0), expectedType: Self.self)
        }
    }
}

// MARK: - Encoding

extension BuildOperationDiagnosticComponent: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        switch self {
        case let .task(taskID, parentTaskID):
            return [
                .int64(0),
                .array([
                    .int64(taskID),
                    .int64(parentTaskID),
                ]),
            ]
            
        case let .unknown(unknown):
            return [
                .int64(1),
                unknown,
            ]
                
        case .global:
            return [
                .int64(2),
                .nil,
            ]
        }
    }
}
