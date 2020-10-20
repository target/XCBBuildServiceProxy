import Foundation
import MessagePack
import XCBProtocol

public struct BuildOperationTaskMetrics {
    public let utime: UInt64
    public let stime: UInt64
    public let maxRSS: UInt64
    public let wcStartTime: UInt64
    public let wcDuration: UInt64
    
    public init(
        utime: UInt64,
        stime: UInt64,
        maxRSS: UInt64,
        wcStartTime: UInt64,
        wcDuration: UInt64
    ) {
        self.utime = utime
        self.stime = stime
        self.maxRSS = maxRSS
        self.wcStartTime = wcStartTime
        self.wcDuration = wcDuration
    }
}

// MARK: - Decoding

extension BuildOperationTaskMetrics: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 5 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.utime = try args.parseUInt64(indexPath: indexPath + IndexPath(index: 0))
        self.stime = try args.parseUInt64(indexPath: indexPath + IndexPath(index: 1))
        self.maxRSS = try args.parseUInt64(indexPath: indexPath + IndexPath(index: 2))
        self.wcStartTime = try args.parseUInt64(indexPath: indexPath + IndexPath(index: 3))
        self.wcDuration = try args.parseUInt64(indexPath: indexPath + IndexPath(index: 4))
    }
}

// MARK: - Encoding

extension BuildOperationTaskMetrics: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [
            .uint64(utime),
            .uint64(stime),
            .uint64(maxRSS),
            .uint64(wcStartTime),
            .uint64(wcDuration),
        ]
    }
}
