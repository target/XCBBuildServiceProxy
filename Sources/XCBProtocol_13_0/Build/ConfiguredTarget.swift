import Foundation
import MessagePack
import XCBProtocol

public struct ConfiguredTarget: Decodable {
    public let guid: String
    public let parameters: BuildParameters?
}
