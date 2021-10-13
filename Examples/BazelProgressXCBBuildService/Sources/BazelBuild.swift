import Foundation
import XCBBuildServiceProxy
import XCBProtocol
@_exported import XCBProtocol_13_0

// swiftformat:disable braces

final class BazelBuild {
    
    private let buildContext: BuildContext<BazelXCBBuildServiceResponsePayload>
    private let buildProcess: BazelBuildProcess
    
    private var buildProgress: Double = -1.0
    private var initialActionCount: Int = 0
    private var totalActions: Int = 0
    private var completedActions: Int = 0
    
    /// This regex is used to minimally remove the timestamp at the start of our messages.
    /// After that we try to parse out the execution progress
    /// (see https://github.com/bazelbuild/bazel/blob/9bea69aee3acf18b780b397c8c441ac5715d03ae/src/main/java/com/google/devtools/build/lib/buildtool/ExecutionProgressReceiver.java#L150-L157 ).
    /// Finally we throw away any " ... (8 actions running)" like messages (see https://github.com/bazelbuild/bazel/blob/4f0b710e2b935b4249e0bbf633f43628bbf93d7b/src/main/java/com/google/devtools/build/lib/runtime/UiStateTracker.java#L1158 ).
    private static let progressRegex = try! NSRegularExpression(
        pattern: #"^(?:\(\d{1,2}:\d{1,2}:\d{1,2}\) )?(?:\[(\d{1,3}(,\d{3})*) \/ (\d{1,3}(,\d{3})*)\] )?(?:(?:INFO|ERROR|WARNING): )?(.*?)(?: \.\.\. \(.*\))?$"#
    )
    
    init(buildContext: BuildContext<BazelXCBBuildServiceResponsePayload>) throws {
        self.buildContext = buildContext
        self.buildProcess = BazelClient()
    }
    
    func start() throws {
        try buildProcess.start(
            bepHandler: { [buildContext] event in
                var progressMessage: String?
                event.progress.stdout.split(separator: "\n").forEach { message in
                    guard !message.isEmpty else { return }
                    
                    let message = String(message)
                    logger.info("message out: \(message)")
                }
                
                event.progress.stderr.split(separator: "\n").forEach { message in
                    guard !message.isEmpty else { return }
                    
                    let message = String(message)
                    logger.info("message err: \(message)")
                    
                    if
                        let match = Self.progressRegex.firstMatch(
                            in: message,
                            options: [],
                            range: NSRange(message.startIndex ..< message.endIndex, in: message)
                        ),
                        match.numberOfRanges == 6,
                        let finalMessageRange = Range(match.range(at: 5), in: message),
                        let completedActionsRange = Range(match.range(at: 1), in: message),
                        let totalActionsRange = Range(match.range(at: 3), in: message)
                    {
                        progressMessage = String(message[finalMessageRange])
                        
                        let completedActionsString = message[completedActionsRange]
                            .replacingOccurrences(of: ",", with: "")
                        let totalActionsString = message[totalActionsRange]
                            .replacingOccurrences(of: ",", with: "")
                        
                        if
                            let completedActions = Int(completedActionsString),
                            let totalActions = Int(totalActionsString)
                        {
                            self.totalActions = totalActions
                            self.completedActions = completedActions
                            if self.initialActionCount == 0, completedActions > 0, completedActions != totalActions {
                                self.initialActionCount = completedActions
                            }
                            
                            self.buildProgress = 100 * Double(completedActions - self.initialActionCount) / Double(totalActions - self.initialActionCount)
                        } else {
                            logger.error("Failed to parse progress out of BEP message: \(message)")
                        }
                    }
                }
                
                if event.lastMessage {
                    progressMessage = progressMessage ?? "Compilation complete"
                    self.buildProgress = 100
                }
                
                // Take the last message in the case of multiple lines, as well as the most recent `buildProgress`
                if let message = progressMessage {
                    buildContext.progressUpdate(message, completedTasks: "\(self.completedActions)/\(self.totalActions)", percentComplete: self.buildProgress)
                }
            }
        )
    }
    
    func cancel() {
        buildProcess.stop()
    }
}


private extension BuildContext where ResponsePayload == BazelXCBBuildServiceResponsePayload {
    func progressUpdate(_ message: String, completedTasks: String, percentComplete: Double, showInLog: Bool = false) {
        sendResponseMessage(
            BuildOperationProgressUpdated(
                statusMessage: message,
                completedTasks: completedTasks,
                percentComplete: percentComplete,
                showInLog: showInLog
            )
        )
    }
}
