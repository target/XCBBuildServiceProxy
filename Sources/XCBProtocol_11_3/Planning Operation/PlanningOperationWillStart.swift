import Foundation
import MessagePack
import XCBProtocol

public struct PlanningOperationWillStart {
    public let sessionHandle: String
    public let guid: String
    
    public init(sessionHandle: String, guid: String) {
        self.sessionHandle = sessionHandle
        self.guid = guid
    }
}

// MARK: - ResponsePayloadConvertible

extension PlanningOperationWillStart: ResponsePayloadConvertible {
    public func toResponsePayload() -> ResponsePayload { .planningOperationWillStart(self) }
}

// MARK: - Decoding

extension PlanningOperationWillStart: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 2 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.sessionHandle = try args.parseString(indexPath: indexPath + IndexPath(index: 0))
        self.guid = try args.parseString(indexPath: indexPath + IndexPath(index: 1))
    }
}

// MARK: - Encoding

extension PlanningOperationWillStart: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [.string(sessionHandle), .string(guid)]
    }
}
