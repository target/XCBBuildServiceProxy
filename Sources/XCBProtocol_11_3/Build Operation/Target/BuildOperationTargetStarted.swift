import Foundation
import MessagePack
import XCBProtocol

public struct BuildOperationTargetStarted {
    public let targetID: Int64
    public let guid: String // Used in `CreateBuildRequest` and `BuildOperationTargetUpToDate`
    public let targetInfo: BuildOperationTargetInfo
    
    public init(targetID: Int64, guid: String, targetInfo: BuildOperationTargetInfo) {
        self.targetID = targetID
        self.guid = guid
        self.targetInfo = targetInfo
    }
}

// MARK: - ResponsePayloadConvertible

extension BuildOperationTargetStarted: ResponsePayloadConvertible {
    public func toResponsePayload() -> ResponsePayload { .buildOperationTargetStarted(self) }
}

// MARK: - Decoding

extension BuildOperationTargetStarted: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 3 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.targetID = try args.parseInt64(indexPath: indexPath + IndexPath(index: 0))
        self.guid = try args.parseString(indexPath: indexPath + IndexPath(index: 1))
        self.targetInfo = try args.parseObject(indexPath: indexPath + IndexPath(index: 2))
    }
}

// MARK: - Encoding

extension BuildOperationTargetStarted: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [
            .int64(targetID),
            .string(guid),
            .array(targetInfo.encode()),
        ]
    }
}
