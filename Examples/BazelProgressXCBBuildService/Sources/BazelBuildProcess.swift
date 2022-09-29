import Foundation
import src_main_java_com_google_devtools_build_lib_buildeventstream_proto_build_event_stream_proto
import SwiftProtobuf

protocol BazelBuildProcess {
    func start(bepHandler: @escaping (BuildEventStream_BuildEvent) -> Void) throws
    func stop()
}

enum BazelBuildProcessError: Error {
    case alreadyStarted
    case failedToCreateBEPFile
}

/// Encapsulates a child Bazel script process.
final class BazelClient: BazelBuildProcess {
    /// Queue used to ensure proper ordering of results from process output/termination.
    private let processResultsQueue = DispatchQueue(
        label: "BazelXCBBuildService.BazelBuildProcess",
        qos: .userInitiated
    )
    
    private var isRunning = false
    private var isCancelled = false
    private let process: Process
    private let bepPath: String
    
    init() {
        //RAPPI: We use the same BEP path as XCBuildKit
        self.bepPath = "/tmp/bep.bep"
        print("BEP Path: \(self.bepPath)")
        self.process = Process()
        
        // Automatically terminate process if our process exits
        let selector = Selector(("setStartsNewProcessGroup:"))
        if process.responds(to: selector) {
            process.perform(selector, with: false as NSNumber)
        }
    }
    
    func start(bepHandler: @escaping (BuildEventStream_BuildEvent) -> Void) throws {
        guard !process.isRunning else {
            throw BazelBuildProcessError.alreadyStarted
        }
        
        let fileManager = FileManager.default

        fileManager.createFile(atPath: bepPath, contents: Data())
        guard let bepFileHandle = FileHandle(forReadingAtPath: bepPath) else {
            logger.error("Failed to create file for BEP stream at “\(bepPath)”")
            throw BazelBuildProcessError.failedToCreateBEPFile
        }
        
        /// Dispatch group used to ensure that stdout and stderr are processed before the process termination.
        /// This is needed since all three notifications come in on different threads.
        let processDispatchGroup = DispatchGroup()
        
        /// `true` if the `terminationHandler` has been called. Xcode will crash if we send more events after that.
        var isTerminated = false
        
        // Bazel works by appending content to a file, specifically, Java's `BufferedOutputStream`.
        // Naively using an input stream for the path and waiting for available data simply does not work with
        // whatever `BufferedOutputStream.flush()` is doing internally.
        //
        // Reference:
        // https://github.com/bazelbuild/bazel/blob/master/src/main/java/com/google/devtools/build/lib/buildeventstream/transports/FileTransport.java
        //
        // Perhaps, SwiftProtobuf can come up with a better solution to read from files or upstream similar code:
        // https://github.com/apple/swift-protobuf/issues/130
        //
        // Logic:
        // - Create a few file
        // - When the build starts, Bazel will attempt to reuse the inode, and stream to it
        // - Then, via `FileHandle`, wait for data to be available and read all the bytes
        bepFileHandle.readabilityHandler = { [processResultsQueue] _ in
            // `bepFileHandle` is captured in the closure, which keeps the reference around
            let data = bepFileHandle.availableData
            guard !data.isEmpty else {
                return
            }
            
            processDispatchGroup.enter()
            processResultsQueue.async {
                defer { processDispatchGroup.leave() }
                
                // We don't want to report any more progress if the build has been terminated
                guard !isTerminated else {
                    bepFileHandle.closeFile()
                    bepFileHandle.readabilityHandler = nil
                    return
                }
                
                // Wrap the file handle in an `InputStream` for SwiftProtobuf to read
                // We read the stream until the (current) end of the file
                let input = InputStream(data: data)
                input.open()
                while input.hasBytesAvailable {
                    do {
                        let event = try BinaryDelimited.parse(messageType: BuildEventStream_BuildEvent.self, from: input)

                        logger.trace("Received BEP event: \(event)")

                        bepHandler(event)

                        if event.lastMessage {
                            logger.trace("Received last BEP event")

                            bepFileHandle.closeFile()
                            bepFileHandle.readabilityHandler = nil
                        }
                    } catch {
                        logger.error("Failed to parse BEP event: \(error)")
                        return
                    }
                }
            }
        }
        
        let stdout = Pipe()
        let stderr = Pipe()
        
        processDispatchGroup.enter()
        stdout.fileHandleForReading.readabilityHandler = { [processResultsQueue] handle in
            let data = handle.availableData
            guard !data.isEmpty else {
                logger.trace("Received Bazel standard output EOF")
                stdout.fileHandleForReading.readabilityHandler = nil
                processDispatchGroup.leave()
        
                return
            }
            
            processResultsQueue.async {
                logger.trace("Received Bazel standard output: \(data)")
            }
        }
        
        processDispatchGroup.enter()
        stderr.fileHandleForReading.readabilityHandler = { [processResultsQueue] handle in
            let data = handle.availableData
            guard !data.isEmpty else {
                logger.trace("Received Bazel standard error EOF")
                stderr.fileHandleForReading.readabilityHandler = nil
                processDispatchGroup.leave()
                return
            }
            
            processResultsQueue.async {
                logger.trace("Received Bazel standard error: \(data)")
            }
        }

        process.standardOutput = stdout
        process.standardError = stderr
        
        processDispatchGroup.enter()
        process.terminationHandler = { process in
            logger.debug("xcode.sh exited with status code: \(process.terminationStatus)")
            processDispatchGroup.leave()
        }
        
        processDispatchGroup.notify(queue: processResultsQueue) {
            logger.info("\(self.isCancelled ? "Cancelled Bazel" : "Bazel") build exited with status code: \(self.process.terminationStatus)")
            isTerminated = true
        }
    }
    
    func stop() {
        isCancelled = true
        if process.isRunning {
            // Sends SIGTERM to the Bazel client. It will cleanup and exit.
            process.terminate()
        }
    }
}
