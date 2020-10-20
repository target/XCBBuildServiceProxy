import Foundation
import MessagePack
import XCBProtocol

public struct PreviewInfoResponse {
    public let targetGUID: String // Called `targetID` by Xcode
    public let infos: [PreviewInfo] // Not named correctly
    
    public init(targetGUID: String, infos: [PreviewInfo]) {
        self.targetGUID = targetGUID
        self.infos = infos
    }
}

// MARK: - ResponsePayloadConvertible

extension PreviewInfoResponse: ResponsePayloadConvertible {
    public func toResponsePayload() -> ResponsePayload { .previewInfo(self) }
}

// MARK: - Decoding

extension PreviewInfoResponse: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 2 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.targetGUID = try args.parseString(indexPath: indexPath + IndexPath(index: 0))
        
        let infosIndexPath = indexPath + IndexPath(index: 1)
        let infosArray = try args.parseArray(indexPath: infosIndexPath)
        self.infos = try infosArray.enumerated().map { index, _ in
            try infosArray.parseObject(indexPath: infosIndexPath + IndexPath(index: index))
        }
    }
}

// MARK: - Encoding

extension PreviewInfoResponse: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [
            .string(targetGUID),
            .array(infos.map { .array($0.encode()) }),
        ]
    }
}
