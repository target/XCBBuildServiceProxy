import Foundation
import MessagePack
import XCBProtocol

public struct BuildOperationReportPathMap {
    public let unknown1: MessagePackValue
    public let unknown2: MessagePackValue
    
    public init() {
        self.unknown1 = .map([:])
        self.unknown2 = .map([:])
    }
}

// MARK: - ResponsePayloadConvertible

extension BuildOperationReportPathMap: ResponsePayloadConvertible {
    public func toResponsePayload() -> ResponsePayload { .buildOperationReportPathMap(self) }
}

// MARK: - Decoding

extension BuildOperationReportPathMap: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 2 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.unknown1 = try args.parseUnknown(indexPath: indexPath + IndexPath(index: 0))
        self.unknown2 = try args.parseUnknown(indexPath: indexPath + IndexPath(index: 1))
    }
}

extension BuildOperationReportPathMap: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [
            unknown1,
            unknown2,
        ]
    }
}
