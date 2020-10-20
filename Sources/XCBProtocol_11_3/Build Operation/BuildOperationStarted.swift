import Foundation
import MessagePack
import XCBProtocol

public struct BuildOperationStarted {
    public let buildNumber: Int64
    
    public init(buildNumber: Int64) {
        self.buildNumber = buildNumber
    }
}

// MARK: - ResponsePayloadConvertible

extension BuildOperationStarted: ResponsePayloadConvertible {
    public func toResponsePayload() -> ResponsePayload { .buildOperationStarted(self) }
}

// MARK: - Decoding

extension BuildOperationStarted: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 1 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.buildNumber = try args.parseInt64(indexPath: indexPath + IndexPath(index: 0))
    }
}

// MARK: - Encoding

extension BuildOperationStarted: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [.int64(buildNumber)]
    }
}
