import Foundation
import MessagePack
import XCBProtocol

public enum BuildCommand: Int64, Decodable {
    case build
    case prepareForIndexing
    case migrate
    case generateAssemblyCode
    case generatePreprocessedFile
    case cleanBuildFolder
    case preview
}

// MARK: - Decoding

extension BuildCommand: CustomDecodableRPCPayload {
    public init(values: [MessagePackValue], indexPath: IndexPath) throws {
        let rawValue = try values.parseInt64(indexPath: indexPath)
        
        guard let parsed = Self(rawValue: rawValue) else {
            throw RPCPayloadDecodingError.incorrectValueType(indexPath: indexPath, expectedType: Self.self)
        }
        
        self = parsed
    }
}
