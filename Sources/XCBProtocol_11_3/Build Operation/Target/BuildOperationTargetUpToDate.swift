import Foundation
import MessagePack
import XCBProtocol

public struct BuildOperationTargetUpToDate {
    public let guid: String
    
    public init(guid: String) {
        self.guid = guid
    }
}

// MARK: - ResponsePayloadConvertible

extension BuildOperationTargetUpToDate: ResponsePayloadConvertible {
    public func toResponsePayload() -> ResponsePayload { .buildOperationTargetUpToDate(self) }
}

// MARK: - Decoding

extension BuildOperationTargetUpToDate: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 1 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.guid = try args.parseString(indexPath: indexPath + IndexPath(index: 0))
    }
}

// MARK: - Encoding

extension BuildOperationTargetUpToDate: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [.string(guid)]
    }
}
