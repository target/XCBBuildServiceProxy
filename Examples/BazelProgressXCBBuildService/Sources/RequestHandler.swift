import Foundation
import Logging
import NIO
import XCBBuildServiceProxy
import XCBProtocol

@_exported import XCBProtocol_13_0
typealias BazelXCBBuildServiceRequestPayload = XCBProtocol_13_0.RequestPayload
typealias BazelXCBBuildServiceResponsePayload = XCBProtocol_13_0.ResponsePayload

final class RequestHandler: HybridXCBBuildServiceRequestHandler {
    typealias Context = HybridXCBBuildServiceRequestHandlerContext<BazelXCBBuildServiceRequestPayload, BazelXCBBuildServiceResponsePayload>
    
    private typealias SessionHandle = String
    private var sessionBazelBuilds: [SessionHandle: BazelBuild] = [:]
    
    func handleRequest(_ request: RPCRequest<BazelXCBBuildServiceRequestPayload>, context: Context) {
        defer {
            // We are injecting Bazel progress but the build is still in charge of the original XCBBuildService
            context.forwardRequest()
        }
        
        switch request.payload {
        case let .createBuildRequest(message):
            // Only showing progress of build command
            guard message.buildRequest.buildCommand.command == .build else { return }
            let session = message.sessionHandle
            // Reset in case we decide not to build
            sessionBazelBuilds[session]?.cancel()
            sessionBazelBuilds[session] = nil
            
            logger.info("Response channel: \(message.responseChannel)")
            
            let buildContext = BuildContext(
                sendResponse: context.sendResponse,
                session: session,
                buildNumber: -1, // Fixed build number since we are not compiling
                responseChannel: message.responseChannel
            )
            
            do {
                self.sessionBazelBuilds[session] = try BazelBuild(buildContext: buildContext)
            } catch {
                context.sendErrorResponse(error, session: session, request: request)
            }
        case let .buildStartRequest(message):
            let session = message.sessionHandle
            guard let build = sessionBazelBuilds[session] else { return }
            do {
                try build.start()
            } catch {
                context.sendErrorResponse(error, session: session, request: request)
            }
        case let .buildCancelRequest(message):
            sessionBazelBuilds[message.sessionHandle]?.cancel()
        default: break
        }
    }
}
