import Foundation
import MessagePack
import XCBProtocol

public struct BuildOperationTargetInfo {
    public let name: String
    public let typeName: String // e.g. "Native" or "Aggregate"
    public let projectInfo: BuildOperationProjectInfo
    public let configurationName: String // e.g. "Debug"
    public let configurationIsDefault: Bool
    public let sdkRoot: String // e.g. "/Applications/Xcode-11.3.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.2.sdk"
    
    public init(
        name: String,
        typeName: String,
        projectInfo: BuildOperationProjectInfo,
        configurationName: String,
        configurationIsDefault: Bool,
        sdkRoot: String
    ) {
        self.name = name
        self.typeName = typeName
        self.projectInfo = projectInfo
        self.configurationName = configurationName
        self.configurationIsDefault = configurationIsDefault
        self.sdkRoot = sdkRoot
    }
}

// MARK: - Decoding

extension BuildOperationTargetInfo: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 6 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.name = try args.parseString(indexPath: indexPath + IndexPath(index: 0))
        self.typeName = try args.parseString(indexPath: indexPath + IndexPath(index: 1))
        self.projectInfo = try args.parseObject(indexPath: indexPath + IndexPath(index: 2))
        self.configurationName = try args.parseString(indexPath: indexPath + IndexPath(index: 3))
        self.configurationIsDefault = try args.parseBool(indexPath: indexPath + IndexPath(index: 4))
        self.sdkRoot = try args.parseString(indexPath: indexPath + IndexPath(index: 5))
    }
}

// MARK: - Encoding

extension BuildOperationTargetInfo: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [
            .string(name),
            .string(typeName),
            .array(projectInfo.encode()),
            .string(configurationName),
            .bool(configurationIsDefault),
            .string(sdkRoot),
        ]
    }
}
