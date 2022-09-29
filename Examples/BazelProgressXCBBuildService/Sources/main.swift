import Foundation
import Logging
import NIO
import XCBBuildServiceProxy

LoggingSystem.bootstrap { label in
    var handler = StreamLogHandler.standardError(label: label)
    
    let logLevel: Logger.Level
    switch ProcessInfo.processInfo.environment["BAZELXCBBUILDSERVICE_LOGLEVEL"]?.lowercased() {
    case "debug": logLevel = .debug
    case "trace": logLevel = .trace
    default: logLevel = .info
    }
    
    handler.logLevel = logLevel
    return handler
}

let logger = Logger(label: "BazelXCBBuildService")

let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

let threadPool = NIOThreadPool(numberOfThreads: System.coreCount)
threadPool.start()

let fileIO = NonBlockingFileIO(threadPool: threadPool)

do {
    let service = try HybridXCBBuildService(
        name: "BazelXCBBuildService",
        group: group,
        fileIO: fileIO,
        requestHandler: RequestHandler()
    )

    do {
        let channel = try service.start()
        try channel.closeFuture.wait()
    } catch {
        logger.error("\(error)")
    }

    service.stop()
} catch {
    logger.critical("\(error)")
}
