import Logging
import NIO
import os
import XCBProtocol

// swiftformat:disable braces
// swiftlint:disable opening_brace

public protocol HybridXCBBuildServiceRequestHandler {
    associatedtype RequestPayload: XCBProtocol.RequestPayload
    associatedtype ResponsePayload: XCBProtocol.ResponsePayload
    
    func handleRequest(
        _ request: RPCRequest<RequestPayload>,
        context: HybridXCBBuildServiceRequestHandlerContext<RequestPayload, ResponsePayload>
    )
}

public final class HybridXCBBuildServiceRequestHandlerContext<RequestPayload, ResponsePayload> where
    RequestPayload: XCBProtocol.RequestPayload,
    ResponsePayload: XCBProtocol.ResponsePayload
{
    public typealias Request = RPCRequest<RequestPayload>
    public typealias Response = RPCResponse<ResponsePayload>
    
    private let forwardRequestProxy: () -> Void
    private let sendRequestProxy: (_ request: Request) -> EventLoopFuture<Response>
    private let sendResponseProxy: (_ response: Response) -> Void
    
    // TODO: Hide Swift NIO
    public let eventLoop: EventLoop
    public let allocator: ByteBufferAllocator
    
    init(
        eventLoop: EventLoop,
        allocator: ByteBufferAllocator,
        forwardRequest: @escaping () -> Void,
        sendRequest: @escaping (_ request: Request) -> EventLoopFuture<Response>,
        sendResponse: @escaping (_ response: Response) -> Void
    ) {
        self.eventLoop = eventLoop
        self.allocator = allocator
        self.forwardRequestProxy = forwardRequest
        self.sendRequestProxy = sendRequest
        self.sendResponseProxy = sendResponse
    }
    
    public func forwardRequest() {
        forwardRequestProxy()
    }
    
    public func sendRequest(_ request: Request) -> EventLoopFuture<Response> {
        return sendRequestProxy(request)
    }
    
    public func sendResponse(_ response: Response) {
        sendResponseProxy(response)
    }
    
    public func sendResponseMessage(_ payload: ResponsePayload, channel: UInt64) {
        sendResponse(Response(channel: channel, payload: payload))
    }
    
    public func sendResponseMessage<PayloadConvertible>(_ payloadConvertible: PayloadConvertible, channel: UInt64) where
        PayloadConvertible: ResponsePayloadConvertible,
        PayloadConvertible.Payload == ResponsePayload
    {
        sendResponse(Response(channel: channel, payloadConvertible: payloadConvertible))
    }
    
    public func sendErrorResponse(
        _ error: Error,
        session: String?,
        request: Request,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        sendErrorResponse(
            "\(session.flatMap { "[\($0)] " } ?? "")\(error)",
            request: request,
            file: file, function: function, line: line
        )
    }
    
    public func sendErrorResponse(
        _ messageClosure: @autoclosure () -> String,
        request: Request,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        let message = messageClosure()
        sendResponseMessage(.errorResponse(message.description), channel: request.channel)
    }
}
