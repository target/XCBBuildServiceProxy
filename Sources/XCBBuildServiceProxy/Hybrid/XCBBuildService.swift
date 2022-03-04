import Foundation
import Logging
import NIO
import os
import XCBProtocol

// swiftformat:disable braces
// swiftlint:disable opening_brace

/// Encapsulates a child XCBBuildService process.
///
/// Communication takes place over the Swift NIO `channel`.
final class XCBBuildService {
    private static let serviceRelativePath = "/Contents/SharedFrameworks/XCBuild.framework/PlugIns/XCBBuildService.bundle/Contents/MacOS/XCBBuildService"
    
    private let process: Process
    
    let channel: Channel
    
    init(process: Process, channel: Channel) {
        self.process = process
        self.channel = channel
    }
    
    private func servicePath(with xcodePath: String) -> String {
        return xcodePath + Self.serviceRelativePath
    }
    
    func startIfNeeded(xcodePath: String) {
        let defaultProcessPath = servicePath(with: xcodePath)
        let originalProcessPath = defaultProcessPath + ".original"
        
        let processPath: String
        if FileManager.default.fileExists(atPath: originalProcessPath) {
            processPath = originalProcessPath
        } else {
            guard defaultProcessPath != CommandLine.arguments[0] else {
                fatalError("HybridXCBBuildService installation requires XCBBuildService to be at \(defaultProcessPath)")
            }
            processPath = defaultProcessPath
        }
        
        guard !process.isRunning else {
            if process.launchPath != processPath {
                let launchPath = process.launchPath ?? ""
                os_log(.error, "XCBBuildService start request for “\(processPath)” but it’s already running at “\(launchPath)”")
            }
            return
        }
        
        os_log(.info, "Starting XCBBuildService at “\(processPath)”")
        
        process.launchPath = processPath
        process.launch()
    }
    
    func stop() {
        process.terminate()
    }
}

final class XCBBuildServiceBootstrap<RequestPayload, ResponsePayload> where
    RequestPayload: XCBProtocol.RequestPayload,
    ResponsePayload: XCBProtocol.ResponsePayload
{
    private let bootstrap: NIOPipeBootstrap
    
    init(group: EventLoopGroup) {
        self.bootstrap = NIOPipeBootstrap(group: group)
            .channelInitializer { channel in
                let framingHandler = RPCPacketCodec(label: "XCBBuildService")
                
                return channel.pipeline.addHandlers([
                    // Bytes -> RPCPacket from XCBBBuildService
                    ByteToMessageHandler(framingHandler),
                    // RPCPacket -> Bytes to XCBBBuildService
                    MessageToByteHandler(framingHandler),
                    // RPCPacket -> RPCResponse from XCBBBuildService
                    RPCResponseDecoder<ResponsePayload>(),
                    // RPCRequests from BazelXCBBuildService, RPCResponses from XCBBBuildService
                    ProxiedRPCRequestHandler<RequestPayload, ResponsePayload>(),
                ])
            }
    }
    
    func create() -> EventLoopFuture<XCBBuildService> {
        let stdin = Pipe()
        let stdout = Pipe()
        let stderr = Pipe()
        
        let process = Process()
        
        process.standardInput = stdin
        process.standardOutput = stdout
        process.standardError = stderr
        
        stderr.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty else {
                os_log(.debug, "Received XCBBuildService standard error EOF")
                stderr.fileHandleForReading.readabilityHandler = nil
                return
            }
            
            if let output = String(data: data, encoding: .utf8) {
                os_log(.info, "XCBBuildService stderr: \(output)")
            }
        }
        
        process.terminationHandler = { process in
            os_log(.info, "XCBBuildService exited with status code: \(process.terminationStatus)")
        }
        
        os_log(.info, "Prepping XCBBuildService")
        
        let channelFuture = bootstrap.withPipes(
            inputDescriptor: stdout.fileHandleForReading.fileDescriptor,
            outputDescriptor: stdin.fileHandleForWriting.fileDescriptor
        )
        
        // Automatically terminate process if our process exits
        let selector = Selector(("setStartsNewProcessGroup:"))
        if process.responds(to: selector) {
            process.perform(selector, with: false as NSNumber)
        }
            
        channelFuture
            .whenSuccess { _ in
                os_log(.info, "XCBBuildService prepped")
            }
        
        return channelFuture.map { XCBBuildService(process: process, channel: $0) }
    }
}
