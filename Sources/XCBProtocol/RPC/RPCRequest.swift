import Foundation
import MessagePack
import NIO
import os

/// An RPC request sent from Xcode.
public struct RPCRequest<Payload: RequestPayload>: CustomStringConvertible {
    public var description: String { "Channel: \(channel) - Payload: \(payload) "}
    
    public let channel: UInt64
    public let payload: Payload
    
    /// Currently, instead of re-encoding requests when sending them to XCBBuildService, we send the original packet along.
    let forwardPacket: RPCPacket
}

// MARK: - Decoder

public final class RPCRequestDecoder<Payload: RequestPayload>: ChannelInboundHandler {
    public typealias InboundIn = RPCPacket
    public typealias InboundOut = RPCRequest<Payload>
    public typealias OutboundOut = RPCPacket
    
    public init() {}
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let request = RPCRequest<Payload>(unwrapInboundIn(data))
        
        os_log("RPCRequest decoded: \(request)")
        
        context.fireChannelRead(wrapInboundOut(request))
    }
}

extension RPCRequest {
    init(_ packet: RPCPacket) {
        let payload: Payload
        do {
            payload = try packet.body.parseObject(indexPath: IndexPath())
        } catch {
            let errorStr = "\(error)"
            os_log("Failed parsing RequestPayload received from Xcode: \(errorStr)\nValues: \(packet.body)")
            
            payload = .unknownRequest(values: packet.body)
        }
        
        self.init(
            channel: packet.channel,
            payload: payload,
            forwardPacket: packet
        )
    }
}

extension RPCPacket {
    public init<Payload: RequestPayload>(_ request: RPCRequest<Payload>) {
        self = request.forwardPacket
    }
}
