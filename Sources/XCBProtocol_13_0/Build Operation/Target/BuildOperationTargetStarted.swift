import Foundation
import MessagePack
import XCBProtocol

public struct BuildOperationTargetStarted: Decodable {
    public let targetID: Int64
    public let guid: String // Used in `CreateBuildRequest` and `BuildOperationTargetUpToDate`
    public let targetInfo: BuildOperationTargetInfo
    
    enum CodingKeys: String, CodingKey {
        case targetID = "id"
        case guid
        case targetInfo = "info"
    }
    
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
