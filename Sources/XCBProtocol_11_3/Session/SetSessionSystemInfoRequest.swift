import Foundation
import MessagePack
import XCBProtocol

public struct SetSessionSystemInfoRequest {
    public let sessionHandle: String
    public let osMajorVersion: UInt64
    public let osMinorVersion: UInt64
    public let osPatchVersion: UInt64
    public let xcodeBuildVersion: String // Called `productBuildVersion` by Xcode
    public let nativeArchitecture: String
}

extension SetSessionSystemInfoRequest: CustomDecodableRPCPayload {
    public init(values: [MessagePackValue], indexPath: IndexPath) throws {
        guard values.count == 5 else { throw RPCPayloadDecodingError.invalidCount(values.count, indexPath: indexPath) }
        
        // Name is at index 0
        let argsIndexPath = indexPath + IndexPath(index: 1)
        let args = try values.parseArray(indexPath: argsIndexPath)

        self.sessionHandle = try args.parseString(indexPath: argsIndexPath + IndexPath(index: 0))
        self.osMajorVersion = try args.parseUInt64(indexPath: argsIndexPath + IndexPath(index: 1))
        self.osMinorVersion = try args.parseUInt64(indexPath: argsIndexPath + IndexPath(index: 2))
        
        self.osPatchVersion = try values.parseUInt64(indexPath: indexPath + IndexPath(index: 2))
        self.xcodeBuildVersion = try values.parseString(indexPath: indexPath + IndexPath(index: 3))
        self.nativeArchitecture = try values.parseString(indexPath: indexPath + IndexPath(index: 4))
    }
}
