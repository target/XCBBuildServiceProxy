import Foundation
import MessagePack
import XCBProtocol

public struct IndexingInfoRequest: Decodable {
    public let sessionHandle: String
    public let responseChannel: UInt64
    public let buildRequest: BuildRequest
    public let targetGUID: String
    public let filePath: String
    public let outputPathOnly: Bool
    
    enum CodingKeys: String, CodingKey {
        case sessionHandle
        case responseChannel
        case buildRequest = "request"
        case targetGUID = "targetID"
        case filePath
        case outputPathOnly
    }
}
