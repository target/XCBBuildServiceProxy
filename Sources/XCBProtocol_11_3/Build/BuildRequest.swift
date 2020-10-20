import Foundation
import MessagePack
import XCBProtocol

public struct BuildRequest {
    public let parameters: BuildParameters
    public let configuredTargets: [ConfiguredTarget]
    public let continueBuildingAfterErrors: Bool
    public let hideShellScriptEnvironment: Bool
    public let useParallelTargets: Bool
    public let useImplicitDependencies: Bool
    public let useDryRun: Bool
    public let showNonLoggedProgress: Bool
    public let buildPlanDiagnosticsDirPath: String?
    public let buildCommand: BuildCommand
    public let schemeCommand: SchemeCommand
    public let buildOnlyTheseFiles: MessagePackValue
    public let useLegacyBuildLocations: Bool
    public let shouldCollectMetrics: Bool
}

// MARK: - Decoding

extension BuildRequest: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 14 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.parameters = try args.parseObject(indexPath: indexPath + IndexPath(index: 0))
        
        let targetsIndexPath = indexPath + IndexPath(index: 1)
        let targetGUIDsArray = try args.parseArray(indexPath: targetsIndexPath)
        self.configuredTargets = try targetGUIDsArray.enumerated().map { index, _ in
            try targetGUIDsArray.parseObject(indexPath: targetsIndexPath + IndexPath(index: index))
        }
        
        self.continueBuildingAfterErrors = try args.parseBool(indexPath: indexPath + IndexPath(index: 2))
        self.hideShellScriptEnvironment = try args.parseBool(indexPath: indexPath + IndexPath(index: 3))
        self.useParallelTargets = try args.parseBool(indexPath: indexPath + IndexPath(index: 4))
        self.useImplicitDependencies = try args.parseBool(indexPath: indexPath + IndexPath(index: 5))
        self.useDryRun = try args.parseBool(indexPath: indexPath + IndexPath(index: 6))
        self.showNonLoggedProgress = try args.parseBool(indexPath: indexPath + IndexPath(index: 7))
        self.buildPlanDiagnosticsDirPath = try args.parseOptionalString(indexPath: indexPath + IndexPath(index: 8))
        self.buildCommand = try args.parseObject(indexPath: indexPath + IndexPath(index: 9))
        self.schemeCommand = try args.parseObject(indexPath: indexPath + IndexPath(index: 10))
        self.buildOnlyTheseFiles = try args.parseUnknown(indexPath: indexPath + IndexPath(index: 11))
        self.useLegacyBuildLocations = try args.parseBool(indexPath: indexPath + IndexPath(index: 12))
        self.shouldCollectMetrics = try args.parseBool(indexPath: indexPath + IndexPath(index: 13))
    }
}
