import Foundation
import Logging
import NIO
import os
import XCBProtocol

// swiftlint:disable opening_brace

final class HybridRPCRequestHandler<RequestHandler: HybridXCBBuildServiceRequestHandler>: ChannelDuplexHandler {
    public typealias InboundIn = RPCRequest<RequestHandler.RequestPayload> // From Xcode
    
    public typealias OutboundIn = RPCResponse<RequestHandler.ResponsePayload> // From XCBBuildService
    public typealias OutboundOut = RPCResponse<RequestHandler.ResponsePayload> // To Xcode
    
    typealias Request = InboundIn
    typealias Response = OutboundIn
    
    private let fileIO: NonBlockingFileIO
    private let xcbBuildService: XCBBuildService
    private let requestHandler: RequestHandler
    
    private var responsePromises: [UInt64: EventLoopPromise<Response>] = [:]
    
    init(fileIO: NonBlockingFileIO, xcbBuildService: XCBBuildService, requestHandler: RequestHandler) {
        self.fileIO = fileIO
        self.xcbBuildService = xcbBuildService
        self.requestHandler = requestHandler
    }
    
    func channelActive(context: ChannelHandlerContext) {
        // Register the response channel on the XCBBuildService channel
        xcbBuildService.channel.triggerUserOutboundEvent(
            ProxiedRPCRequestHandlerEvent.registerResponseChannel(context.channel),
            promise: nil
        )
        
        context.fireChannelActive()
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        // Here we are receiving a request from Xcode
        let request = unwrapInboundIn(data)
        
        os_log(.debug, "Received RPCRequest from Xcode: \(request)")
        
        // Start the proxied XCBBuildService if needed
        if let xcodePath = request.payload.createSessionXcodePath {
            xcbBuildService.startIfNeeded(xcodePath: xcodePath)
        }
        
        let requestHandlerContext = HybridXCBBuildServiceRequestHandlerContext(
            eventLoop: context.eventLoop,
            allocator: context.channel.allocator,
            forwardRequest: { self.sendRequest(request, context: context, promise: nil) },
            sendRequest: { self.sendRequest($0, context: context) },
            sendResponse: { response in
                // Ensure we are on the right event loop
                if context.eventLoop.inEventLoop {
                    self.sendResponse(response, context: context)
                } else {
                    context.eventLoop.execute {
                        self.sendResponse(response, context: context)
                    }
                }
            }
        )
        
        requestHandler.handleRequest(request, context: requestHandlerContext)
    }
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        // Here we are receiving a response from XCBBuildService
        let response = unwrapOutboundIn(data)
        
        // Return a result for `sendRequest()`
        if let promise = responsePromises.removeValue(forKey: response.channel) {
            os_log(.debug, "Received RPCResponse from XCBBuildService: \(response)")
            promise.succeed(response)
        } else {
            // Unknown channel, because of event stream or forwarded request
            // Just forward it back to Xcode
            os_log(.debug, "Received RPCResponse from XCBBuildService and sending to Xcode: \(response)")
            context.writeAndFlush(data, promise: promise)
        }
    }
    
    private func sendRequest(_ request: Request, context: ChannelHandlerContext, promise: EventLoopPromise<Response>?) {
        if let promise = promise {
            responsePromises[request.channel] = promise
        }
        
        os_log(.debug, "Sending RPCRequest to XCBBuildService: \(request)")
        
        xcbBuildService.channel.writeAndFlush(request, promise: nil)
    }
    
    private func sendRequest(_ request: Request, context: ChannelHandlerContext) -> EventLoopFuture<Response> {
        let promise = context.eventLoop.makePromise(of: Response.self)
        
        sendRequest(request, context: context, promise: promise)
        
        return promise.futureResult
    }
    
    private func sendResponse(_ response: Response, context: ChannelHandlerContext) {
        os_log(.debug, "Sending RPCResponse to Xcode: \(response)")
        context.writeAndFlush(wrapOutboundOut(response), promise: nil)
    }
}
