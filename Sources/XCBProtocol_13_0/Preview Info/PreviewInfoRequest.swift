import Foundation
import MessagePack
import XCBProtocol

public struct PreviewInfoRequest: Decodable {
    public let sessionHandle: String
    public let responseChannel: UInt64
    public let buildRequest: BuildRequest // Called `request` by Xcode
    public let targetGUID: String // Called `targetID` by Xcode
    public let sourceFile: String // e.g. "/Full/Path/To/Project/Source/File.swift"
    public let thunkVariantSuffix: String // e.g. "__XCPREVIEW_THUNKSUFFIX__"
    
    enum CodingKeys: String, CodingKey {
        case sessionHandle
        case responseChannel
        case buildRequest = "request"
        case targetGUID = "targetID"
        case sourceFile
        case thunkVariantSuffix
    }
}
