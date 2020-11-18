import Foundation
import NIO

final class QueryXcodeVersion {
    private let process: Process
    
    init(appPath: String) {
        self.process = Process()
        process.launchPath = "/usr/libexec/PlistBuddy"
        process.arguments = [
            "-c",
            "Print :ProductBuildVersion",
            "\(appPath)/Contents/version.plist",
        ]
        
        // Automatically terminate process if our process exits
        let selector = Selector(("setStartsNewProcessGroup:"))
        if process.responds(to: selector) {
            process.perform(selector, with: false as NSNumber)
        }
    }

    func start(eventLoop: EventLoop) -> EventLoopFuture<String> {
        let promise = eventLoop.makePromise(of: String.self)
        
        let stdout = Pipe()
        let stderr = Pipe()
        
        stdout.fileHandleForReading.readabilityHandler = { handle in
            // We only process a single line
            defer { stdout.fileHandleForReading.readabilityHandler = nil }
            
            let data = handle.availableData
            guard !data.isEmpty else {
                logger.trace("Received QueryXcodeVersion standard output EOF")
                return
            }
            
            if let response = String(data: data, encoding: .utf8) {
                promise.succeed(response.trimmingCharacters(in: .whitespacesAndNewlines))
            } else {
                logger.error("Failed to decode response for QueryXcodeVersion")
                promise.succeed("")
            }
        }

        process.standardOutput = stdout
        process.standardError = stderr
        
        process.terminationHandler = { process in
            logger.debug("QueryXcodeVersion exited with status code: \(process.terminationStatus)")
        }
        
        let command = "\(process.launchPath!) \(process.arguments!.joined(separator: " "))"

        logger.info("Querying Xcode version with command: \(command)")
        
        process.launch()
        
        return promise.futureResult
    }
}
