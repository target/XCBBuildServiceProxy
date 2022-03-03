import Foundation
import MessagePack
import XCBProtocol

public struct SetSessionUserInfoRequest: Decodable {
    public let sessionHandle: String
    public let user: String
    public let group: String
    public let uid: Int64
    public let gid: Int64
    public let home: String
    public let xcodeProcessEnvironment: [String: String]?
    public let buildSystemEnvironment: [String: String]
    public let usePerConfigurationBuildDirectories: Bool?
}
