import Foundation
import MessagePack
import XCBProtocol

public struct BuildParameters: Decodable {
    public let action: String // e.g. "build", "clean"
    public let configuration: String // e.g. "Debug", "Release"
    public let activeRunDestination: RunDestinationInfo
    public let activeArchitecture: String // e.g. "x86_64", "arm64"
    public let arenaInfo: ArenaInfo
    public let overrides: SettingsOverrides
    
    enum CodingKeys: String, CodingKey {
        case action
        case configuration
        case activeRunDestination
        case activeArchitecture
        case arenaInfo
        case overrides
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.action = try values.decode(String.self, forKey: .action)
        self.configuration = try values.decodeIfPresent(String.self, forKey: .configuration) ?? ""
        self.activeRunDestination = try values.decode(RunDestinationInfo.self, forKey: .activeRunDestination)
        self.activeArchitecture = try values.decode(String.self, forKey: .activeArchitecture)
        self.arenaInfo = try values.decode(ArenaInfo.self, forKey: .arenaInfo)
        self.overrides = try values.decode(SettingsOverrides.self, forKey: .overrides)
    }
}
