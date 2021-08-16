import Foundation
import MessagePack
import XCBProtocol

public struct BuildOperationTaskEnded {
    public let taskID: Int64
    public let status: BuildOperationStatus
    public let skippedErrorsFromSerializedDiagnostics: Bool // Might be named "signalled"
    public let metrics: BuildOperationTaskMetrics?
    
    public init(taskID: Int64, status: BuildOperationStatus, skippedErrorsFromSerializedDiagnostics: Bool, metrics: BuildOperationTaskMetrics?) {
        self.taskID = taskID
        self.status = status
        self.skippedErrorsFromSerializedDiagnostics = skippedErrorsFromSerializedDiagnostics
        self.metrics = metrics
    }
}

// MARK: - ResponsePayloadConvertible

extension BuildOperationTaskEnded: ResponsePayloadConvertible {
    public func toResponsePayload() -> ResponsePayload { .buildOperationTaskEnded(self) }
}

// MARK: - Decoding

extension BuildOperationTaskEnded: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 4 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.taskID = try args.parseInt64(indexPath: indexPath + IndexPath(index: 0))
        self.status = try args.parseObject(indexPath: indexPath + IndexPath(index: 1))
        self.skippedErrorsFromSerializedDiagnostics = try args.parseBool(indexPath: indexPath + IndexPath(index: 2))
        self.metrics = try args.parseOptionalObject(indexPath: indexPath + IndexPath(index: 3))
    }
}

// MARK: - Encoding

extension BuildOperationTaskEnded: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [
            .int64(taskID),
            .int64(status.rawValue),
            .bool(skippedErrorsFromSerializedDiagnostics),
            metrics.flatMap { MessagePackValue.array($0.encode()) } ?? .nil,
        ]
    }
}
