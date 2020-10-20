import Foundation
import MessagePack
import XCBProtocol

public struct ConfiguredTarget {
    public let guid: String
    public let parameters: BuildParameters?
}

// MARK: - Decoding

extension ConfiguredTarget: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 2 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.guid = try args.parseString(indexPath: indexPath + IndexPath(index: 0))
        self.parameters = try args.parseOptionalObject(indexPath: indexPath + IndexPath(index: 1))
    }
}
