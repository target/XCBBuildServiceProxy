import Foundation
import MessagePack
import XCBProtocol

public struct BuildOperationProjectInfo {
    public let name: String
    public let path: String
    public let isPackage: Bool
    
    public init(name: String, path: String, isPackage: Bool) {
        self.name = name
        self.path = path
        self.isPackage = isPackage
    }
}

// MARK: - Decoding

extension BuildOperationProjectInfo: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 3 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.name = try args.parseString(indexPath: indexPath + IndexPath(index: 0))
        self.path = try args.parseString(indexPath: indexPath + IndexPath(index: 1))
        self.isPackage = try args.parseBool(indexPath: indexPath + IndexPath(index: 2))
    }
}

// MARK: - Encoding

extension BuildOperationProjectInfo: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [
            .string(name),
            .string(path),
            .bool(isPackage),
        ]
    }
}
