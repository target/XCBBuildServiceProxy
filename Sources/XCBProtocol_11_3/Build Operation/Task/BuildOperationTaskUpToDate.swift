import Foundation
import MessagePack
import XCBProtocol

public struct BuildOperationTaskUpToDate {
    public let taskGUID: Data
    public let targetID: Int64
    public let unknown: MessagePackValue
}

// MARK: - ResponsePayloadConvertible

extension BuildOperationTaskUpToDate: ResponsePayloadConvertible {
    public func toResponsePayload() -> ResponsePayload { .buildOperationTaskUpToDate(self) }
}

// MARK: - Decoding

extension BuildOperationTaskUpToDate: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 3 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.taskGUID = try args.parseBinary(indexPath: indexPath + IndexPath(index: 0))
        self.targetID = try args.parseInt64(indexPath: indexPath + IndexPath(index: 1))
        self.unknown = try args.parseUnknown(indexPath: indexPath + IndexPath(index: 2))
    }
}

// MARK: - Encoding

extension BuildOperationTaskUpToDate: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [
            .binary(taskGUID),
            .int64(targetID),
            unknown,
        ]
    }
}
