import Foundation
import MessagePack
import XCBProtocol

public struct IndexingInfoRequest: Decodable {
    public let sessionHandle: String
    public let responseChannel: UInt64
    public let buildRequest: BuildRequest // Called `request` by Xcode
    public let targetGUID: String // Called `targetID` by Xcode
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
