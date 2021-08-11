import Foundation
import MessagePack
import XCBProtocol

public struct BuildOperationTargetInfo: Decodable {
    public let name: String
    public let typeName: String // e.g. "Native" or "Aggregate"
    public let projectInfo: BuildOperationProjectInfo
    public let configurationName: String // e.g. "Debug"
    public let configurationIsDefault: Bool
    public let sdkRoot: String? // e.g. "/Applications/Xcode-11.3.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.2.sdk"
    
    public init(
        name: String,
        typeName: String,
        projectInfo: BuildOperationProjectInfo,
        configurationName: String,
        configurationIsDefault: Bool,
        sdkRoot: String?
    ) {
        self.name = name
        self.typeName = typeName
        self.projectInfo = projectInfo
        self.configurationName = configurationName
        self.configurationIsDefault = configurationIsDefault
        self.sdkRoot = sdkRoot
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
            sdkRoot.flatMap { .string($0) } ?? .nil,
        ]
    }
}
