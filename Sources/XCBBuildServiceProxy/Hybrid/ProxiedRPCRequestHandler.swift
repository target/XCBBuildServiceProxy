import NIO
import XCBProtocol

// swiftformat:disable braces
// swiftlint:disable opening_brace

enum ProxiedRPCRequestHandlerEvent {
    case registerResponseChannel(Channel)
}

final class ProxiedRPCRequestHandler<RequestPayload, ResponsePayload>: ChannelDuplexHandler where
    RequestPayload: XCBProtocol.RequestPayload,
    ResponsePayload: XCBProtocol.ResponsePayload
{
    typealias InboundIn = RPCResponse<ResponsePayload> // From XCBBuildService
    
    typealias OutboundIn = RPCRequest<RequestPayload> // From Xcode/BazelXCBBuildService
    typealias OutboundOut = RPCPacket // To XCBBuildService
    
    // This needs to be set in `triggerUserOutboundEvent`
    var responseChannel: Channel!
    
    func triggerUserOutboundEvent(context: ChannelHandlerContext, event: Any, promise: EventLoopPromise<Void>?) {
        if case let .registerResponseChannel(channel) = event as? ProxiedRPCRequestHandlerEvent {
            responseChannel = channel
        } else {
            context.triggerUserOutboundEvent(event, promise: promise)
        }
    }
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        // This will be invoked from BazelXCBBuildService
        let request = unwrapOutboundIn(data)
        let packet = RPCPacket(request)
        context.write(wrapOutboundOut(packet), promise: promise)
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        // This will be invoked from XCBBuildService
        let response = unwrapInboundIn(data)
        responseChannel.write(response, promise: nil)
    }
}
