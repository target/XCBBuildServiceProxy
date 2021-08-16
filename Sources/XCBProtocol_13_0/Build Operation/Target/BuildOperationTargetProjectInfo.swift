import Foundation
import MessagePack
import XCBProtocol

public struct BuildOperationProjectInfo: Decodable {
    public let name: String
    public let path: String
    public let isPackage: Bool
    public let isNameUniqueInWorkspace: Bool
    
    public init(name: String, path: String, isPackage: Bool, isNameUniqueInWorkspace: Bool) {
        self.name = name
        self.path = path
        self.isPackage = isPackage
        self.isNameUniqueInWorkspace = isNameUniqueInWorkspace
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
