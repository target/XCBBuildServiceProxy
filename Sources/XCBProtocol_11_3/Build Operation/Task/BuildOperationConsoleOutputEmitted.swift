import Foundation
import MessagePack
import XCBProtocol

public struct BuildOperationConsoleOutputEmitted {
    public let taskID: Int64
    public let unknown: MessagePackValue
    public let output: Data
    
    public init(taskID: Int64, output: Data) {
        self.taskID = taskID
        self.unknown = .nil
        self.output = output
    }
}

// MARK: - ResponsePayloadConvertible

extension BuildOperationConsoleOutputEmitted: ResponsePayloadConvertible {
    public func toResponsePayload() -> ResponsePayload { .buildOperationConsoleOutput(self) }
}

// MARK: - Decoding

extension BuildOperationConsoleOutputEmitted: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 3 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.output = try args.parseBinary(indexPath: indexPath + IndexPath(index: 0))
        self.unknown = try args.parseUnknown(indexPath: indexPath + IndexPath(index: 1))
        self.taskID = try args.parseInt64(indexPath: indexPath + IndexPath(index: 2))
    }
}

// MARK: - Encoding

extension BuildOperationConsoleOutputEmitted: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [
            .binary(output),
            unknown,
            .int64(taskID),
        ]
    }
}
