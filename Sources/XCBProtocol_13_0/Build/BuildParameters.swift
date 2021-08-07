import Foundation
import MessagePack
import XCBProtocol

public struct BuildParameters: Decodable {
    public let action: String // e.g. "build", "clean"
//    public let configuration: String // e.g. "Debug", "Release"
    public let activeRunDestination: RunDestinationInfo
    public let activeArchitecture: String // e.g. "x86_64", "arm64"
    public let arenaInfo: ArenaInfo
    public let overrides: SettingsOverrides
//    public let xbsParameters: MessagePackValue
    
    public var configuration: String { "Debug" }
}
