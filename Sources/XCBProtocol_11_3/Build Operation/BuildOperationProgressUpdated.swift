import Foundation
import MessagePack
import XCBProtocol

public struct BuildOperationProgressUpdated {
    public let targetName: String?
    public let statusMessage: String
    public let percentComplete: Double
    public let showInLog: Bool
    
    public init(targetName: String?, statusMessage: String, percentComplete: Double, showInLog: Bool) {
        self.targetName = targetName
        self.statusMessage = statusMessage
        self.percentComplete = percentComplete
        self.showInLog = showInLog
    }
}

// MARK: - ResponsePayloadConvertible

extension BuildOperationProgressUpdated: ResponsePayloadConvertible {
    public func toResponsePayload() -> ResponsePayload { .buildOperationProgressUpdated(self) }
}

// MARK: - Decoding

extension BuildOperationProgressUpdated: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 4 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.targetName = try args.parseOptionalString(indexPath: indexPath + IndexPath(index: 0))
        self.statusMessage = try args.parseString(indexPath: indexPath + IndexPath(index: 1))
        self.percentComplete = try args.parseDouble(indexPath: indexPath + IndexPath(index: 2))
        self.showInLog = try args.parseBool(indexPath: indexPath + IndexPath(index: 3))
    }
}

// MARK: - Encoding

extension BuildOperationProgressUpdated: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [
            targetName.flatMap { .string($0) } ?? .nil,
            .string(statusMessage),
            .double(percentComplete),
            .bool(showInLog),
        ]
    }
}
