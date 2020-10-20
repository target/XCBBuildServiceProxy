import Foundation
import NIO
import XCBProtocol

public final class HybridXCBBuildService<RequestHandler: HybridXCBBuildServiceRequestHandler> {
    private let name: String
    private let group: EventLoopGroup
    private let bootstrap: NIOPipeBootstrap
    
    // TODO: Move NIO specific stuff into class
    public init(name: String, group: EventLoopGroup, fileIO: NonBlockingFileIO, requestHandler: RequestHandler) throws {
        self.name = name
        self.group = group
        
        let xcbBuildServiceBootstrap = XCBBuildServiceBootstrap<RequestHandler.RequestPayload, RequestHandler.ResponsePayload>(group: group)
        
        let xcbBuildServiceFuture = xcbBuildServiceBootstrap.create()
        
        self.bootstrap = NIOPipeBootstrap(group: group)
            .channelInitializer { channel in
                xcbBuildServiceFuture.flatMap { xcbBuildService in
                    let framingHandler = RPCPacketCodec(label: "HybridXCBBuildService(\(name))")
                    
                    return channel.pipeline.addHandlers([
                        // Bytes -> RPCPacket from Xcode
                        ByteToMessageHandler(framingHandler),
                        // RPCPacket -> Bytes to Xcode
                        MessageToByteHandler(framingHandler),
                        // RPCPacket -> RPCRequest from Xcode
                        RPCRequestDecoder<RequestHandler.RequestPayload>(),
                        // RPCResponse -> RPCPacket to Xcode
                        RPCResponseEncoder<RequestHandler.ResponsePayload>(),
                        // RPCRequests from Xcode, RPCResponses from XCBBuildService
                        HybridRPCRequestHandler<RequestHandler>(
                            fileIO: fileIO,
                            xcbBuildService: xcbBuildService,
                            requestHandler: requestHandler
                        ),
                    ])
                }
            }
    }
    
    public func start() throws -> Channel {
        let channel = try bootstrap.withPipes(inputDescriptor: STDIN_FILENO, outputDescriptor: STDOUT_FILENO).wait()
        
        logger.info("\(name) started and listening on STDIN")
        
        return channel
    }
    
    public func stop() {
        do {
            try group.syncShutdownGracefully()
        } catch {
            logger.error("Error shutting down: \(error)")
            exit(0)
        }
        logger.info("\(name) stopped")
    }
}
