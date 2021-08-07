import Foundation
import MessagePack
import XCBProtocol

public struct BuildRequest: Decodable {
    public let parameters: BuildParameters
    public let configuredTargets: [ConfiguredTarget]
    public let continueBuildingAfterErrors: Bool
    public let hideShellScriptEnvironment: Bool
    public let useParallelTargets: Bool
    public let useImplicitDependencies: Bool
    public let useDryRun: Bool
    public let showNonLoggedProgress: Bool
    public let buildCommand: BuildCommand
    public let schemeCommand: SchemeCommand
    public let buildDescriptionID: String?
    public let shouldCollectMetrics: Bool
    public let jsonRepresentation: String?
}

