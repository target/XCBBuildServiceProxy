import Foundation
import MessagePack
import XCBProtocol

public struct CreateBuildRequest: Decodable {
    public let sessionHandle: String
    public let responseChannel: UInt64
    public let buildRequest: BuildRequest
    public let onlyCreateBuildDescription: Bool
    
    enum CodingKeys: String, CodingKey {
        case sessionHandle
        case responseChannel
        case buildRequest = "request"
        case onlyCreateBuildDescription
    }
}
