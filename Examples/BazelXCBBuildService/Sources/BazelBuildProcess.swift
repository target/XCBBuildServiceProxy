import Foundation
import src_main_java_com_google_devtools_build_lib_buildeventstream_proto_build_event_stream_proto
import SwiftProtobuf

protocol BazelBuildProcess {
    func start(
        startedHandler: @escaping (
            _ uniqueTargetsHandler: @escaping (
                _ targetPatterns: String,
                _ workingDirectory: String,
                _ environment: [String: String],
                _ finishStartup: @escaping (_ buildLabelsResult: Result<[String], Error>) -> Void
            ) -> Void,
            _ startProcessHandler: @escaping (_ finalTargetPatterns: String, _ workingDirectory: String, _ environment: [String: String]) -> String
        ) -> Void,
        outputHandler: @escaping (Data) -> Void,
        bepHandler: @escaping (BuildEventStream_BuildEvent) -> Void,
        terminationHandler: @escaping (_ exitCode: Int32, _ cancelled: Bool) -> Void
    ) throws

    func stop()
}

enum BazelBuildProcessError: Error {
    case alreadyStarted
    case failedToCreateBEPFile
    case failToParseUniqueTargetsOutput
    case uniqueTargetsFailed(_ exitCode: Int32)
}

/// Encapsulates a child Bazel script process.
final class BazelClient: BazelBuildProcess {
    /// Queue used to ensure proper ordering of results from process output/termination.
    private let processResultsQueue = DispatchQueue(
        label: "BazelXCBBuildService.BazelBuildProcess",
        qos: .userInitiated
    )
    private let process: Process
    private let uniqueTargetsProcess: UniqueTargetsProcess
    
    private var isCancelled = false
    
    private let bepPath: String
    
    init() {
        //RAPPI: We use the same BEP path as XCBuildKit since it was first implemented in Rappi
        self.bepPath = "/tmp/bep.bep"
//        self.bepPath = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
//            .appendingPathComponent(ProcessInfo().globallyUniqueString).path
        print("BEP Path: \(self.bepPath)")
        self.process = Process()
        
        // Automatically terminate process if our process exits
        let selector = Selector(("setStartsNewProcessGroup:"))
        if process.responds(to: selector) {
            process.perform(selector, with: false as NSNumber)
        }

        self.uniqueTargetsProcess = UniqueTargetsProcess()
    }
    
    func start(
        startedHandler: @escaping (
            _ uniqueTargetsHandler: @escaping (
                _ targetPatterns: String,
                _ workingDirectory: String,
                _ environment: [String: String],
                _ finishStartup: @escaping (_ buildLabelsResult: Result<[String], Error>) -> Void
            ) -> Void,
            _ startProcessHandler: @escaping (_ finalTargetPatterns: String, _ workingDirectory: String, _ environment: [String: String]) -> String
        ) -> Void,
        outputHandler: @escaping (Data) -> Void,
        bepHandler: @escaping (BuildEventStream_BuildEvent) -> Void,
        terminationHandler: @escaping (_ exitCode: Int32, _ cancelled: Bool) -> Void
    ) throws {
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
                outputHandler(data)
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
                outputHandler(data)
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
            terminationHandler(self.process.terminationStatus, self.isCancelled)
            isTerminated = true
        }
        
        startedHandler(
            { [uniqueTargetsProcess] targetPatterns, workingDirectory, environment, finishStartup in
                uniqueTargetsProcess.start(
                    targetPatterns: targetPatterns,
                    workingDirectory: workingDirectory,
                    environment: environment,
                    errorOutputHandler: outputHandler,
                    uniqueBuildLabelsHandler: finishStartup
                )
            },
            { [process, bepPath] finalTargetPatterns, workingDirectory, environment in
                //RAPPI: We handle our own Bazel build process
                return ""
//                var environment = environment
//                environment["NBS_BEP_PATH"] = bepPath
//
//                process.launchPath = "/bin/bash"
//                process.currentDirectoryPath = workingDirectory
//                process.environment = environment
//                process.arguments = [
//                    "-c",
//                    "bazel/xcode.sh nbs \(finalTargetPatterns)",
//                ]
//
//                let command = "\(process.launchPath!) \(process.arguments!.joined(separator: " "))"
//                logger.info("Starting Bazel with command: \(command)")
//
//                process.launch()
//
//                return """
//                cd \(process.currentDirectoryPath)
//                \(
//                    (process.environment ?? [:])
//                        .sorted { $0.key < $1.key }
//                        .map { "export \($0)=\($1.exportQuoted)" }
//                        .joined(separator: "\n")
//                )
//                \(command)
//                """
            }
        )
    }
    
    func stop() {
        isCancelled = true
        if process.isRunning {
            // Sends SIGTERM to the Bazel client. It will cleanup and exit.
            process.terminate()
        }
    }
}

final class CleanBuildFolderProcess: BazelBuildProcess {
    /// Queue used to ensure proper ordering of results from process output/termination.
    private let processResultsQueue = DispatchQueue(
        label: "BazelXCBBuildService.CleanBuildFolderProcess",
        qos: .userInitiated
    )
    private let process: Process
    
    private var isCancelled = false
    
    init(buildProductsPath: String, buildIntermediatesPath: String) {
        self.process = Process()
        process.launchPath = "/bin/rm"
        process.arguments = [
            "-r",
            buildProductsPath,
            buildIntermediatesPath,
        ]
        
        // Automatically terminate process if our process exits
        let selector = Selector(("setStartsNewProcessGroup:"))
        if process.responds(to: selector) {
            process.perform(selector, with: false as NSNumber)
        }
    }

    func start(
        startedHandler: @escaping (
            _ uniqueTargetsHandler: @escaping (
                _ targetPatterns: String,
                _ workingDirectory: String,
                _ environment: [String: String],
                _ finishStartup: @escaping (_ buildLabelsResult: Result<[String], Error>) -> Void
            ) -> Void,
            _ startProcessHandler: @escaping (_ finalTargetPatterns: String, _ workingDirectory: String, _ environment: [String: String]) -> String
        ) -> Void,
        outputHandler: @escaping (Data) -> Void,
        bepHandler: @escaping (BuildEventStream_BuildEvent) -> Void,
        terminationHandler: @escaping (_ exitCode: Int32, _ cancelled: Bool) -> Void
    ) throws {
        guard !process.isRunning else {
            throw BazelBuildProcessError.alreadyStarted
        }

        let stdout = Pipe()
        let stderr = Pipe()
        
        stdout.fileHandleForReading.readabilityHandler = { [processResultsQueue] handle in
            let data = handle.availableData
            guard !data.isEmpty else {
                logger.trace("Received CleanBuildFolder standard output EOF")
                stdout.fileHandleForReading.readabilityHandler = nil
                return
            }
            
            processResultsQueue.sync {
                if let output = String(data: data, encoding: .utf8) {
                    logger.error("Received CleanBuildFolder standard output: \(output)")
                }
            }
        }
        
        stderr.fileHandleForReading.readabilityHandler = { [processResultsQueue] handle in
            let data = handle.availableData
            guard !data.isEmpty else {
                logger.trace("Received CleanBuildFolder standard error EOF")
                stderr.fileHandleForReading.readabilityHandler = nil
                return
            }
            
            processResultsQueue.sync {
                if let output = String(data: data, encoding: .utf8) {
                    logger.error("Received CleanBuildFolder standard error: \(output)")
                }
            }
        }

        process.standardOutput = stdout
        process.standardError = stderr
        
        process.terminationHandler = { _ in
            terminationHandler(self.process.terminationStatus, self.isCancelled)
        }
        
        let command = "\(process.launchPath!) \(process.arguments!.joined(separator: " "))"

        logger.info("Cleaning build folder with command: \(command)")
        startedHandler({ $3(.success([])) }, { [process] _, _, _ in
            process.launch()
            return ""
        })
    }

    func stop() {
        isCancelled = true
        if process.isRunning {
            process.terminate()
        }
    }
}

/// Encapsulates a child `tools/UniqueTargets` process.
private final class UniqueTargetsProcess {
    /// Queue used to ensure proper ordering of results from process output/termination.
    private let processResultsQueue = DispatchQueue(
        label: "BazelXCBBuildService.UniqueTargetsProcess",
        qos: .userInitiated
    )
    private let process: Process
    
    private var isCancelled = false
    
    init() {
        self.process = Process()
        
        // Automatically terminate process if our process exits
        let selector = Selector(("setStartsNewProcessGroup:"))
        if process.responds(to: selector) {
            process.perform(selector, with: false as NSNumber)
        }
    }
    
    func start(
        targetPatterns: String,
        workingDirectory: String,
        environment: [String: String],
        errorOutputHandler: @escaping (Data) -> Void,
        uniqueBuildLabelsHandler: @escaping (Result<[String], Error>) -> Void
    ) {
        guard !process.isRunning else {
            uniqueBuildLabelsHandler(.failure(BazelBuildProcessError.alreadyStarted))
            return
        }

        process.launchPath = "/bin/bash"
        process.currentDirectoryPath = workingDirectory
        process.environment = environment
        process.arguments = [
            "-c",
            "tools/UniqueTargets/bin/UniqueTargets \(targetPatterns)",
        ]

        /// Dispatch group used to ensure that stdout and stderr are processed before the process termination.
        /// This is needed since all three notifications come in on different threads.
        let processDispatchGroup = DispatchGroup()

        let stdout = Pipe()
        let stderr = Pipe()

        var collectedData = Data()
        
        processDispatchGroup.enter()
        stdout.fileHandleForReading.readabilityHandler = { [processResultsQueue] handle in
            let data = handle.availableData
            guard !data.isEmpty else {
                logger.trace("Received UniqueTargets standard output EOF")
                stdout.fileHandleForReading.readabilityHandler = nil
                processDispatchGroup.leave()
        
                return
            }

            collectedData.append(data)
            
            processResultsQueue.async {
                logger.trace("Received UniqueTargets standard output: \(data)")
            }
        }

        processDispatchGroup.enter()
        stderr.fileHandleForReading.readabilityHandler = { [processResultsQueue] handle in
            let data = handle.availableData
            guard !data.isEmpty else {
                logger.trace("Received UniqueTargets standard error EOF")
                stderr.fileHandleForReading.readabilityHandler = nil
                processDispatchGroup.leave()
                return
            }

            processResultsQueue.async {
                logger.trace("Received UniqueTargets standard error: \(data)")
                errorOutputHandler(data)
            }
        }

        process.standardOutput = stdout
        process.standardError = stderr

        processDispatchGroup.enter()
        process.terminationHandler = { process in
            logger.debug("UniqueTargets exited with status code: \(process.terminationStatus)")
            processDispatchGroup.leave()
        }

        processDispatchGroup.notify(queue: processResultsQueue) {
            if self.process.terminationStatus == 0 {
                if let uniqueTargetPatterns = String(data: collectedData, encoding: .utf8) {
                    let uniqueBuildLabels = uniqueTargetPatterns
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .components(separatedBy: .whitespaces)
                    uniqueBuildLabelsHandler(.success(uniqueBuildLabels))
                } else {
                    uniqueBuildLabelsHandler(.failure(BazelBuildProcessError.failToParseUniqueTargetsOutput))
                }
            } else {
                uniqueBuildLabelsHandler(.failure(BazelBuildProcessError.uniqueTargetsFailed(self.process.terminationStatus)))
            }
        }
        
        let command = "\(process.launchPath!) \(process.arguments!.joined(separator: " "))"

        logger.info("Starting UniqueTargets with command: \(command)")
        
        process.launch()
    }
    
    func stop() {
        if process.isRunning {
            // Sends SIGTERM to the Bazel client. It will cleanup and exit.
            process.terminate()
        }
    }
}

private extension String {
    var exportQuoted: String {
        guard rangeOfCharacter(from: .whitespacesAndNewlines) != nil else { return self }
        return #""\#(self)""#
    }
}
