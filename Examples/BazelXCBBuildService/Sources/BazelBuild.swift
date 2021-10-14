import Foundation
import XCBBuildServiceProxy
import XCBProtocol
@_exported import XCBProtocol_13_0

// swiftformat:disable braces

final class BazelBuild {
    static let standardArchitectures = ["arm64"]
    
    struct Target {
        let name: String
        let xcodeGUID: String
        let project: Project
        let productTypeIdentifier: String?
        let buildConfigurations: [String: [String: BuildSetting]]
        var parameters: BuildParameters?
    }
    
    // Value semantics, but class because of massive reuse with `Target`.
    final class Project {
        let name: String
        let path: String
        let projectDirectory: String
        let isPackage: Bool
        let buildConfigurations: [String: [String: BuildSetting]]
        
        init(
            name: String,
            path: String,
            projectDirectory: String,
            isPackage: Bool,
            buildConfigurations: [String: [String: BuildSetting]]
        ) {
            self.name = name
            self.path = path
            self.projectDirectory = projectDirectory
            self.isPackage = isPackage
            self.buildConfigurations = buildConfigurations
        }
    }
    
    private let buildContext: BuildContext<BazelXCBBuildServiceResponsePayload>
    private let buildProcess: BazelBuildProcess

    private let baseEnvironment: [String: String]
    private let xcodeBuildVersion: String
    private let developerDir: String
    private let buildRequest: BuildRequest
    
    private var buildProgress: Double = -1.0
    private var initialActionCount: Int = 0
    private var totalActions: Int = 0
    private var completedActions: Int = 0
    
    private let bazelTargets: [(target: Target, label: String, xcodeLabel: String)]
    private let nonBazelTargets: [Target]
    
    private static let diagnosticsRegex = try! NSRegularExpression(
        pattern: #"^(?:(.*?):(\d+):(\d+):\s+)?(error|warning|note):\s*(.*)$"#,
        options: [.caseInsensitive]
    )
    
    /// This regex is used to minimally remove the timestamp at the start of our messages.
    /// After that we try to parse out the execution progress
    /// (see https://github.com/bazelbuild/bazel/blob/9bea69aee3acf18b780b397c8c441ac5715d03ae/src/main/java/com/google/devtools/build/lib/buildtool/ExecutionProgressReceiver.java#L150-L157 ).
    /// Finally we throw away any " ... (8 actions running)" like messages (see https://github.com/bazelbuild/bazel/blob/4f0b710e2b935b4249e0bbf633f43628bbf93d7b/src/main/java/com/google/devtools/build/lib/runtime/UiStateTracker.java#L1158 ).
    private static let progressRegex = try! NSRegularExpression(
        pattern: #"^(?:\(\d{1,2}:\d{1,2}:\d{1,2}\) )?(?:\[(\d{1,3}(,\d{3})*) \/ (\d{1,3}(,\d{3})*)\] )?(?:(?:INFO|ERROR|WARNING): )?(.*?)(?: \.\.\. \(.*\))?$"#
    )
    
    init(
        buildContext: BuildContext<BazelXCBBuildServiceResponsePayload>,
        environment: [String: String],
        xcodeBuildVersion: String,
        developerDir: String,
        buildRequest: BuildRequest,
        targets: [Target]
    ) throws {
        guard !targets.isEmpty else {
            throw BazelBuildError.noTargets
        }
        
        let targetsList = targets.map(\.name).joined(separator: ", ")
        let targetsWording = targets.count == 1 ? "target" : "targets"
        logger.info("Creating a Bazel build for \(targetsWording): \(targetsList)")

        self.baseEnvironment = environment
        self.xcodeBuildVersion = xcodeBuildVersion
        self.developerDir = developerDir
        self.buildRequest = buildRequest
        
        self.buildContext = buildContext

        switch buildRequest.buildCommand.command {
        case .cleanBuildFolder:
            self.buildProcess = CleanBuildFolderProcess(
                buildProductsPath: buildRequest.parameters.arenaInfo.buildProductsPath,
                buildIntermediatesPath: buildRequest.parameters.arenaInfo.buildIntermediatesPath
            )
            self.bazelTargets = []
            self.nonBazelTargets = []

        default:
            self.buildProcess = BazelClient()
            (self.bazelTargets, self.nonBazelTargets) = targets.bazelTargets(
                for: buildRequest.parameters.configuration
            )
        }
    }
    
    /// - Returns: `true` if at least one of the desired targets should be built with Bazel.
    static func shouldBuild(targets: [Target], buildRequest: BuildRequest) -> Bool {
        return targets.contains { $0.shouldBuildWithBazel(configuration: buildRequest.parameters.configuration) }
    }
    
    /// - Returns: `true` if the target shouldn't be build for the `buildRequest`.
    ///   e.g. test targets are set in Xcode 11.3 for SwiftUI previews, even though we don't need to build them.
    static func shouldSkipTarget(_ target: Target, buildRequest: BuildRequest) -> Bool {
        guard buildRequest.buildCommand.command == .preview else { return false }

        return target.name.hasSuffix("Testing")
            || target.name == "TestingCore"
            || [
                "com.apple.product-type.bundle.unit-test",
                "com.apple.product-type.bundle.ui-testing",
            ].contains(target.productTypeIdentifier)
    }
    
    static func previewInfo(
        _ request: PreviewInfoRequest,
        targets: [String: Target],
        baseEnvironment: [String: String],
        xcodeBuildVersion: String
    ) throws -> PreviewInfoResponse {
        let targetGUID = request.targetGUID
        
        guard let target = targets[targetGUID] else {
            throw BazelBuildError.targetNotFound(guid: targetGUID)
        }

        let buildRequest = request.buildRequest
        
        guard shouldBuild(targets: [target], buildRequest: buildRequest) else {
            throw BazelBuildError.dontBuildWithBazel
        }

        let parameters = target.parameters ?? buildRequest.parameters
        let developerDir = baseEnvironment["DEVELOPER_DIR"]!
        let platformDir = "\(developerDir)/Platforms/\(parameters.activeRunDestination.platform.directoryName)"
        let platformDeveloperDir = "\(platformDir)/Developer"
        let sdkRoot = "\(platformDeveloperDir)/SDKs/\(parameters.activeRunDestination.sdkVariant)" //TODO: .directoryName

        let environment = Self.generateEnvironment(
            baseEnvironment: baseEnvironment,
            buildRequest: buildRequest,
            xcodeBuildVersion: xcodeBuildVersion,
            developerDir: developerDir,
            platformDir: platformDir,
            platformDeveloperDir: platformDeveloperDir,
            sdkRoot: sdkRoot,
            target: target
        )
        
        let configuration = parameters.configuration
        
        guard case let .string(rawLabel) = target.buildSetting(Target.bazelLabelBuildSetting, for: configuration) else {
            throw BazelBuildError.bazelLabelNotSet(targetName: target.name)
        }
        
        // Our modules use the wrapper suffix, which we need to strip off
        let label = rawLabel.deletingSuffix(".${SWIFT_PLATFORM_TARGET_PREFIX}_wrapper")
        
        // Convert the label into a directory
        let directory = label.deletingPrefix("//").substringBefore(":")
        
        let package = String(directory.split(separator: "/").last!)
        let sourceIdentifier = String(request.sourceFile.split(separator: "/").last!).deletingSuffix(".swift")
        let thunkVariantSuffix = request.thunkVariantSuffix
        
        let workingDirectory = target.project.projectDirectory
        let flavor = ["Release", "Profile"].contains(configuration) ? "opt" : "dbg"

        let activeRunDestination = parameters.activeRunDestination
        let architecture = activeRunDestination.targetArchitecture
        let os = activeRunDestination.platform.swiftPlatformTargetPrefix

        // We require that IPHONEOS_DEPLOYMENT_TARGET (or the like) is set
        guard let minOSVersion = environment[activeRunDestination.platform.deploymentTargetClangEnvName] else {
            throw BazelBuildError.deploymentTargetNotSet(targetName: target.name)
        }
        
        #if EXPERIMENTAL_XCODE
            let shouldBuildForExperimentXcode = "true"
        #else
            let shouldBuildForExperimentXcode = "false"
        #endif
        
        return PreviewInfoResponse(
            targetGUID: targetGUID,
            infos: [
                PreviewInfo(
                    sdkVariant: activeRunDestination.sdkVariant,
                    buildVariant: "normal",
                    architecture: architecture,
                    // After the first command Xcode inserts arbitrary commands. Our script has to account for that.
                    compileCommandLine: [
                        "\(workingDirectory)/bazel/swiftui-previews.sh",
                        "---",
                        label,
                        sourceIdentifier,
                        thunkVariantSuffix,
                        environment["HOME"]!,
                        os,
                        configuration,
                        workingDirectory,
                        shouldBuildForExperimentXcode,
                    ],
                    // Must not be empty
                    linkCommandLine: ["/usr/bin/true"],
                    // Must be absolute
                    thunkSourceFile: "\(workingDirectory)/\(directory)/.PreviewReplacement/\(sourceIdentifier).\(thunkVariantSuffix).preview-thunk.swift",
                    // Doesn't seem to be used?
                    thunkObjectFile: "",
                    // Must be absolute
                    thunkLibrary: "\(workingDirectory)/bazel-out/\(os)-\(architecture)-min\(minOSVersion)-applebin_\(os)-\(os)_\(architecture)-\(flavor)/bin/\(directory)/\(package).\(sourceIdentifier).\(thunkVariantSuffix).\(os)_previewthunk_bin",
                    pifGUID: targetGUID
                ),
            ]
        )
    }
    
    private static func generateEnvironment(
        baseEnvironment: [String: String],
        buildRequest: BuildRequest,
        xcodeBuildVersion: String,
        developerDir: String,
        platformDir: String,
        platformDeveloperDir: String,
        sdkRoot: String,
        target: Target
    ) -> [String: String] {
        let project = target.project
        let parameters = target.parameters ?? buildRequest.parameters
        let configuration = parameters.configuration
        
        let projectBuildSettings = project.buildConfigurations[configuration] ?? [:]
        let targetBuildSettings = target.buildConfigurations[configuration] ?? [:]
        
        let productName: String
        if case let .string(theProductName) = targetBuildSettings["PRODUCT_NAME"] {
            productName = theProductName
        } else {
            logger.error("PRODUCT_NAME must be explicitly set on \(target.name) for Bazel integration")
            productName = ""
        }

        let activeRunDestination = parameters.activeRunDestination
        
        let effectiveConfiguration = "\(configuration)\(activeRunDestination.platform.effectivePlatform ?? "")"
        let symRoot = parameters.overrides.synthesized["SYMROOT"] ??
            parameters.arenaInfo.buildProductsPath
        let builtProductsDir = "\(symRoot)/\(effectiveConfiguration)"
        let configurationTempDir = "/\(project.name).build/\(effectiveConfiguration)"
        
        let targetBuildDir: String
        if case let .string(testHost) = targetBuildSettings["TEST_HOST"] {
            // TODO: Parse build settings better
            // "$(BUILT_PRODUCTS_DIR)/Example.app/Example" -> "\(buildProductsDir)/Example.app/Example"
            let parsedTestHost = testHost
                .replacingOccurrences(of: "$(BUILT_PRODUCTS_DIR)", with: builtProductsDir)
                .replacingOccurrences(of: "${BUILT_PRODUCTS_DIR}", with: builtProductsDir)
            // "\(buildProductsDir)/Example.app/Example" -> "\(buildProductsDir)/Example.app/PlugIns"
            targetBuildDir = "\((parsedTestHost as NSString).deletingLastPathComponent)/PlugIns"
        } else if targetBuildSettings["TEST_TARGET_NAME"] != nil {
            targetBuildDir = "\(builtProductsDir)/\(productName)-Runner.app/PlugIns"
        } else {
            targetBuildDir = builtProductsDir
        }
        
        // TODO: Handle custom toolchains
        // (look in "/Library/Developer/Toolchains/" for a toolchain that matches `buildRequest.toolchainOverride`)
        let xcodeToolchainDir = "\(developerDir)/Toolchains/XcodeDefault.xctoolchain"
        let toolchainDir = xcodeToolchainDir
        let toolchains = ["com.apple.dt.toolchain.XcodeDefault"]
        
        let validArchitectures = activeRunDestination.supportedArchitectures
            .filter { standardArchitectures.contains($0) }
        let architecture = validArchitectures.first ?? activeRunDestination.targetArchitecture
        
        let paths = [
            "\(toolchainDir)/usr/bin",
            "\(toolchainDir)/usr/local/bin",
            "\(toolchainDir)/usr/libexec",
            "\(platformDir)/usr/bin",
            "\(platformDir)/usr/local/bin",
            "\(platformDeveloperDir)/usr/bin",
            "\(platformDeveloperDir)/usr/local/bin",
            "\(developerDir)/usr/bin",
            "\(developerDir)/usr/local/bin",
            "/usr/local/bin",
            "/usr/bin",
            "/bin",
            "/usr/sbin",
            "/sbin",
        ]

        var defaultBuildSettings = [
            "ACTION": parameters.action,
            "ARCHS": architecture,
            "BUILD_DIR": symRoot,
            "BUILT_PRODUCTS_DIR": builtProductsDir,
            "CONFIGURATION": configuration,
            "CONFIGURATION_TEMP_DIR": configurationTempDir,
            "DEVELOPER_SDK_DIR": sdkRoot,
            "DEPLOYMENT_TARGET_CLANG_ENV_NAME": activeRunDestination.platform.deploymentTargetClangEnvName,
            "DT_TOOLCHAIN_DIR": xcodeToolchainDir,
            "LLVM_TARGET_TRIPLE_VENDOR": "apple",
            "PATH": paths.joined(separator: ":"),
            "PRODUCT_TYPE": target.productTypeIdentifier ?? "",
            "SRCROOT": project.projectDirectory,
            "SWIFT_PLATFORM_TARGET_PREFIX": activeRunDestination.platform.swiftPlatformTargetPrefix,
            "TARGET_BUILD_DIR": targetBuildDir,
            "TOOLCHAIN_DIR": toolchainDir,
            "TOOLCHAINS": toolchains.joined(separator: " "),
        ]
        
        defaultBuildSettings["LLVM_TARGET_TRIPLE_SUFFIX"] = activeRunDestination.platform.llvmTargetTripleSuffix
        
        if let wrapperExtension = target.productTypeIdentifier.flatMap(wrapperExtension) {
            let fullProductName = "\(productName).\(wrapperExtension)"
            defaultBuildSettings["WRAPPER_EXTENSION"] = wrapperExtension
            defaultBuildSettings["WRAPPER_SUFFIX"] = ".\(wrapperExtension)"
            defaultBuildSettings["WRAPPER_NAME"] = fullProductName
            defaultBuildSettings["FULL_PRODUCT_NAME"] = fullProductName
        }
        
        var environment = mergeBuildSettings([
            baseEnvironment,
            defaultBuildSettings,
            parameters.overrides.synthesized,
            projectBuildSettings.asStrings(),
            targetBuildSettings.asStrings(),
        ])
        
        environment["BAZEL_XCODE_PLATFORM_DEVELOPER_DIR"] = platformDeveloperDir
        environment["XCODE_PRODUCT_BUILD_VERSION"] = xcodeBuildVersion

        if buildRequest.continueBuildingAfterErrors {
            environment["NBS_CONTINUE_BUILDING_AFTER_ERRORS"] = "YES"
        }
        
        return environment
    }

    private static func wrapperExtension(for productTypeIdentifier: String) -> String? {
        switch productTypeIdentifier {
        case "com.apple.product-type.application",
             "com.apple.product-type.application.messages",
             "com.apple.product-type.application.watchapp",
             "com.apple.product-type.application.watchapp2",
             "com.apple.product-type.application.watchapp2-container":
            return "app"
            
        case "com.apple.product-type.framework":
            return "framework"
            
        case "com.apple.product-type.bundle":
            return "bundle"
            
        case "com.apple.product-type.bundle.unit-test",
             "com.apple.product-type.bundle.ui-testing":
            return "xctest"
            
        case "com.apple.product-type.app-extension",
             "com.apple.product-type.app-extension.messages",
             "com.apple.product-type.app-extension.messages-sticker-pack",
             "com.apple.product-type.tv-app-extension",
             "com.apple.product-type.watchkit-extension",
             "com.apple.product-type.watchkit2-extension":
            return "appex"
            
        case "com.apple.product-type.xpc-service":
            return "xpc"
            
        default:
            return nil
        }
    }
    
    private static func mergeBuildSettings(_ buildSettings: [[String: String]]) -> [String: String] {
        return buildSettings.reduce(into: [:]) { buildSettings, additionalBuildSettings in
            buildSettings.merge(additionalBuildSettings) { _, new in new }
        }
    }
    
    func start(startedHandler: @escaping () -> Void) throws {
        guard nonBazelTargets.isEmpty else {
            startedHandler()
            buildContext.buildStarted()
            buildContext.diagnostic(
                "Some targets are set to build with Bazel, but \(Target.shouldBuildWithBazelBuildSetting) and/or \(Target.bazelLabelBuildSetting) is not set for the following targets: \(nonBazelTargets.map(\.name).joined(separator: ", ")). All, or none of, the targets need to be setup to build with Bazel.",
                kind: .error,
                appendToOutputStream: true
            )
            buildContext.buildEnded(cancelled: false)
            return
        }

        // This works for now since we only have a single project, but will break if we spread between multiple in the future
        let workingDirectory = bazelTargets.last?.target.project.projectDirectory ?? ""

        var uniquedActions = false
        
        try buildProcess.start(
            startedHandler: { [buildContext, baseEnvironment, xcodeBuildVersion, developerDir, buildRequest, bazelTargets] uniqueTargetsHandler, startProcessHandler in
                startedHandler()

                let actualLabels = bazelTargets.map(\.label)
                let actualTargetPatterns = actualLabels.joined(separator: " ")
                
                buildContext.planningStarted()
                buildContext.progressUpdate("Building with Bazel", percentComplete: -1.0, showInLog: true)
                if !bazelTargets.isEmpty {
                    buildContext.progressUpdate(
                        "Preparing build for \(actualLabels.count == 1 ? "label" : "labels"): \(actualTargetPatterns)",
                        percentComplete: -1.0,
                        showInLog: true
                    )
                }
                
                let finishStartup = { (buildLabelsResult: Result<[String], Error>) in
                    let uniqueActualLabels: [String]
                    switch buildLabelsResult {
                    case let .failure(error):
                        buildContext.diagnostic(
                            "Failed to find unique labels: \(error).\nUsing original label set instead.",
                            kind: .warning
                        )
                        uniqueActualLabels = actualLabels

                    case let .success(newActualLabels):
                        uniqueActualLabels = newActualLabels
                    }

                    if uniquedActions {
                        buildContext.progressUpdate(
                            "Actually building \(uniqueActualLabels.count == 1 ? "label" : "labels"): \(uniqueActualLabels.joined(separator: " "))",
                            percentComplete: -1.0,
                            showInLog: true
                        )
                    }

                    let uniqueBazelTargets = uniqueActualLabels.compactMap { label in bazelTargets.first { $0.label == label } }
                    let target = uniqueBazelTargets.last
                    let installTarget = target?.target

                    if uniqueBazelTargets.count > 1, let lastLabel = target?.label {
                        // Warn that we are only installing the last target
                        buildContext.diagnostic(
                            "More than one target was specified. Currently only the last target (\(lastLabel)) will be installed and runnable.",
                            kind: .info
                        )
                    }
                    buildContext.planningEnded()
                    
                    buildContext.buildStarted()

                    let parameters = installTarget?.parameters ?? buildRequest.parameters
                    let platformDir = "\(developerDir)/Platforms/\(parameters.activeRunDestination.platform.directoryName)"
                    let platformDeveloperDir = "\(platformDir)/Developer"
                    let sdkRoot = "\(platformDeveloperDir)/SDKs/\(parameters.activeRunDestination.sdkVariant)" //TODO: .directoryName
                    let configuration = parameters.configuration

                    let commandLineString = startProcessHandler(
                        uniqueBazelTargets.map(\.xcodeLabel).joined(separator: " "),
                        workingDirectory,
                        installTarget.flatMap {
                            Self.generateEnvironment(
                                baseEnvironment: baseEnvironment,
                                buildRequest: buildRequest,
                                xcodeBuildVersion: xcodeBuildVersion,
                                developerDir: developerDir,
                                platformDir: platformDir,
                                platformDeveloperDir: platformDeveloperDir,
                                sdkRoot: sdkRoot,
                                target: $0
                            )
                        } ?? baseEnvironment
                    )
                    
                    if let installTarget = installTarget {
                        buildContext.targetStarted(
                            id: 0,
                            guid: installTarget.xcodeGUID,
                            targetInfo: BuildOperationTargetInfo(
                                name: installTarget.name,
                                typeName: "Native",
                                projectInfo: BuildOperationProjectInfo(installTarget.project),
                                configurationName: configuration,
                                configurationIsDefault: false,
                                sdkRoot: sdkRoot
                            )
                        )
                        buildContext.taskStarted(
                            id: 1,
                            targetID: 0,
                            taskDetails: BuildOperationTaskStarted.TaskDetails(
                                taskName: "Shell Script Invocation",
                                signature: Data(),
                                ruleInfo: "PhaseScriptExecution Bazel\\ build xcode.sh",
                                executionDescription: "Run custom shell script ‘Bazel build’",
                                commandLineDisplayString: commandLineString.indent(),
                                interestingPath: nil,
                                serializedDiagnosticsPaths: []
                            )
                        )
                    }
                }

                if bazelTargets.count > 1 {
                    buildContext.progressUpdate(
                        "Determining unique targets",
                        percentComplete: -1.0,
                        showInLog: true
                    )

                    uniquedActions = true

                    uniqueTargetsHandler(actualTargetPatterns, workingDirectory, baseEnvironment, finishStartup)
                } else {
                    finishStartup(.success(actualLabels))
                }
            },
            outputHandler: { [buildContext] output in
                buildContext.consoleOutput(output, taskID: 1)
                
                if let stringOutput = String(data: output, encoding: .utf8) {
                    stringOutput.split(separator: "\n").forEach { message in
                        let message = String(message)
                        
                        let kind: BuildOperationDiagnosticKind
                        let location: BuildOperationDiagnosticLocation
                        let finalMessage: String
                        if
                            let match = Self.diagnosticsRegex.firstMatch(
                                in: message,
                                options: [],
                                range: NSRange(message.startIndex ..< message.endIndex, in: message)
                            ),
                            match.numberOfRanges == 6,
                            let kindRange = Range(match.range(at: 4), in: message),
                            let finalMessageRange = Range(match.range(at: 5), in: message)
                        {
                            switch message[kindRange].lowercased() {
                            case "error": kind = .error
                            case "warning": kind = .warning
                            default: kind = .info
                            }
                            
                            finalMessage = String(message[finalMessageRange]).capitalizingFirstLetter()
                            
                            if
                                let fileNameRange = Range(match.range(at: 1), in: message),
                                let lineRange = Range(match.range(at: 2), in: message),
                                let columnRange = Range(match.range(at: 3), in: message)
                            {
                                // TODO: Generate this properly. It might be incorrect for external/generated.
                                let rawFileName = String(message[fileNameRange])
                                let fileName = rawFileName.hasPrefix(workingDirectory) ? rawFileName : "\(workingDirectory)/\(rawFileName)"
                                let line = Int64(message[lineRange]) ?? 0
                                let column = Int64(message[columnRange]) ?? 0
                                location = .locationContext(file: fileName, line: line, column: column)
                            } else {
                                location = .alternativeMessage("")
                            }
                        } else {
                            kind = .info
                            finalMessage = message
                            location = .alternativeMessage("")
                        }
                        
                        buildContext.diagnostic(
                            finalMessage,
                            kind: kind,
                            location: location,
                            component: .task(taskID: 1, targetID: 0)
                        )
                    }
                }
            },
            bepHandler: { [buildContext] event in
                var progressMessage: String?
                event.progress.stderr.split(separator: "\n").forEach { message in
                    guard !message.isEmpty else { return }
                    
                    let message = String(message)
                    
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
                        progressMessage = String(message[finalMessageRange]).components(separatedBy: ";").first
                        
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
                    buildContext.progressUpdate("\(message) \(self.completedActions)/\(self.totalActions)", percentComplete: self.buildProgress)
                }
            },
            terminationHandler: { [buildContext, bazelTargets] exitCode, cancelled in
                logger.info("\(cancelled ? "Cancelled Bazel" : "Bazel") build exited with status code: \(exitCode)")
                
                let succeeded = cancelled || exitCode == 0

                if !bazelTargets.isEmpty {
                    buildContext.taskEnded(id: 1, succeeded: succeeded)
                    if succeeded {
                        buildContext.targetEnded(id: 0)
                    }
                }
                
                buildContext.buildEnded(cancelled: cancelled)
            }
        )
    }
    
    func cancel() {
        buildProcess.stop()
    }
}

enum BazelBuildError: Error {
    case noTargets
    case dontBuildWithBazel
    case productNameRequired(targetName: String)
    case bazelLabelNotSet(targetName: String)
    case deploymentTargetNotSet(targetName: String)
    case targetNotFound(guid: String)
}

private extension BuildContext where ResponsePayload == BazelXCBBuildServiceResponsePayload {
    func planningStarted() {
        sendResponseMessage(PlanningOperationWillStart(sessionHandle: session, guid: ""))
    }

    func planningEnded() {
        sendResponseMessage(PlanningOperationDidFinish(sessionHandle: session, guid: ""))
    }
    
    func buildStarted() {
        sendResponseMessage(BuildOperationPreparationCompleted())
        sendResponseMessage(BuildOperationStarted(buildNumber: buildNumber))
        sendResponseMessage(BuildOperationReportPathMap())
    }
    
    func progressUpdate(_ message: String, percentComplete: Double, showInLog: Bool = false) {
        sendResponseMessage(
            BuildOperationProgressUpdated(
                targetName: nil,
                statusMessage: message,
                percentComplete: percentComplete,
                showInLog: showInLog
            )
        )
    }
    
    func buildEnded(cancelled: Bool) {
        sendResponseMessage(BuildOperationEnded(buildNumber: buildNumber, status: cancelled ? .cancelled : .succeeded))
    }
    
    func targetUpToDate(guid: String) {
        sendResponseMessage(BuildOperationTargetUpToDate(guid: guid))
    }
    
    func targetStarted(id: Int64, guid: String, targetInfo: BuildOperationTargetInfo) {
        sendResponseMessage(BuildOperationTargetStarted(targetID: id, guid: guid, targetInfo: targetInfo))
    }
    
    func targetEnded(id: Int64) {
        sendResponseMessage(BuildOperationTargetEnded(targetID: id))
    }
    
    func taskStarted(id: Int64, targetID: Int64, taskDetails: BuildOperationTaskStarted.TaskDetails) {
        sendResponseMessage(
            BuildOperationTaskStarted(
                taskID: id,
                targetID: targetID,
                parentTaskID: nil,
                taskDetails: taskDetails
            )
        )
    }
    
    func consoleOutput(_ data: Data, taskID: Int64) {
        sendResponseMessage(
            BuildOperationConsoleOutputEmitted(
                taskID: taskID,
                output: data
            )
        )
    }
    
    func diagnostic(
        _ message: String,
        kind: BuildOperationDiagnosticKind,
        location: BuildOperationDiagnosticLocation = .alternativeMessage(""),
        component: BuildOperationDiagnosticComponent = .global,
        appendToOutputStream: Bool = false
    ) {
        sendResponseMessage(
            BuildOperationDiagnosticEmitted(
                kind: kind,
                location: location,
                message: message,
                component: component,
                unknown: "default",
                appendToOutputStream: appendToOutputStream
            )
        )
    }
    
    func taskEnded(id: Int64, succeeded: Bool) {
        sendResponseMessage(
            BuildOperationTaskEnded(
                taskID: id,
                status: succeeded ? .succeeded : .failed,
                skippedErrorsFromSerializedDiagnostics: false,
                metrics: nil
            )
        )
    }
}

extension BazelBuildError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noTargets:
            return "No Bazel valid targets found"
        case .dontBuildWithBazel:
            // This should be caught and handled instead of being reported
            return "Use XCBuild to build"
        case .productNameRequired(let targetName):
            return "PRODUCT_NAME must be explicitly set on \(targetName) for Bazel integration"
        case .bazelLabelNotSet(let targetName):
            return "BAZEL_LABEL must be explicitly set on \(targetName) for Bazel integration"
        case .deploymentTargetNotSet(let targetName):
            return "The deployment target (e.g. IPHONEOS_DEPLOYMENT_TARGET) must be explicitly set on \(targetName) for Bazel integration"
        case .targetNotFound(let guid):
            return "Target with guid \(guid) not found in PIF cache"
        }
    }
}

private extension BazelBuild.Target {
    static let shouldBuildWithBazelBuildSetting = "USE_BAZELXCBBUILDSERVICE"
    static let bazelLabelBuildSetting = "BAZEL_LABEL"
    static let bazelXcodeLabelBuildSetting = "BAZEL_XCODE_LABEL"
    
    func buildSetting(_ name: String, for configuration: String) -> BuildSetting? {
        guard let targetBuildSettings = buildConfigurations[configuration] else {
            return nil
        }
        
        if let targetSetting = targetBuildSettings[name] {
            return targetSetting
        }
        
        return project.buildConfigurations[configuration]?[name]
    }
    
    func shouldBuildWithBazel(configuration: String) -> Bool {
        guard case let .string(setting) = buildSetting(Self.shouldBuildWithBazelBuildSetting, for: configuration) else {
            return false
        }
        return setting == "YES"
    }
}

private extension BuildOperationProjectInfo {
    init(_ parsedProject: BazelBuild.Project) {
        self.init(
            name: parsedProject.name,
            path: parsedProject.path,
            isPackage: parsedProject.isPackage,
            isNameUniqueInWorkspace: true
        )
    }
}

private extension Array where Element == BazelBuild.Target {
    func bazelTargets(for configuration: String) -> (bazelTargets: [(target: BazelBuild.Target, label: String, xcodeLabel: String)], nonBazelTargets: [BazelBuild.Target]) {
        var bazelTargets: [(target: BazelBuild.Target, label: String, xcodeLabel: String)] = []
        var nonBazelTargets: [BazelBuild.Target] = []
        for target in self {
            if
                target.shouldBuildWithBazel(configuration: configuration),
                case let .string(label) = target.buildSetting(BazelBuild.Target.bazelLabelBuildSetting, for: configuration),
                case let .string(xcodeLabel) = target.buildSetting(BazelBuild.Target.bazelXcodeLabelBuildSetting, for: configuration)
            {
                bazelTargets.append((target, label, xcodeLabel))
            } else {
                nonBazelTargets.append(target)
            }
        }
        return (bazelTargets, nonBazelTargets)
    }
}

private extension Dictionary where Value == BuildSetting {
    func asStrings() -> [Key: String] {
        mapValues { setting in
            switch setting {
            case let .string(string): return string
            case let .array(array): return array.joined(separator: " ")
            }
        }
    }
}

private extension String {
    func indent() -> String {
        "    " + replacingOccurrences(of: "\n", with: "\n    ")
    }
}

private extension BuildPlatform {
    // e.g. "IPHONEOS_DEPLOYMENT_TARGET"
    var deploymentTargetClangEnvName: String {
        switch self {
        case .macosx:
            return "MACOSX_DEPLOYMENT_TARGET"

        case .iphoneos, .iphonesimulator:
            return "IPHONEOS_DEPLOYMENT_TARGET"

        case .watchos, .watchsimulator:
            return "WATCHOS_DEPLOYMENT_TARGET"

        case .appletvos, .appletvsimulator:
            return "TVOS_DEPLOYMENT_TARGET"
        }
    }

    // e.g. "iphonesimulator" -> "iPhoneSimulator.platform"
    var directoryName: String {
        return "\(stylizedForDirectoryName).platform"
    }

    // e.g. "iphonesimulator" -> "iPhoneSimulator"
    var stylizedForDirectoryName: String {
        switch self {
        case .macosx:
            return "MacOSX"

        case .iphonesimulator:
            return "iPhoneSimulator"
        case .iphoneos:
            return "iPhoneOS"

        case .watchos:
            return "WatchOS"
        case .watchsimulator:
            return "WatchSimulator"

        case .appletvos:
            return "AppleTVOS"
        case .appletvsimulator:
            return "AppleTVSimulator"
        }
    }

    // e.g. "-iphonesimulator"
    var effectivePlatform: String? {
        guard rawValue != "macosx" else { return nil }
        return "-\(rawValue)"
    }

    // e.g. "-simulator"
    var llvmTargetTripleSuffix: String? {
        switch self {
        case .iphonesimulator, .watchsimulator, .appletvsimulator:
            return "-simulator"
            
        default:
            return nil
        }
    }

    // e.g. "ios", "macos", "tvos"
    var swiftPlatformTargetPrefix: String {
        switch self {
        case .macosx:
            return "macos"

        case .iphoneos, .iphonesimulator:
            return "ios"

        case .watchos, .watchsimulator:
            return "watchos"

        case .appletvos, .appletvsimulator:
            return "tvos"
        }
    }
}

private extension SDKVariant {
    private static let regex = try! NSRegularExpression(pattern: #"^(\D+)(\d+\.\d+)$"#)
    
    // e.g. "iphonesimulator13.2" -> "iPhoneSimulator13.2.sdk"
    var directoryName: String {
        // TODO: Figure this out better
        guard
            let match = Self.regex.firstMatch(
                in: rawValue,
                options: [],
                range: NSRange(rawValue.startIndex ..< rawValue.endIndex, in: rawValue)
            ),
            match.numberOfRanges == 3,
            let nameRange = Range(match.range(at: 1), in: rawValue),
            let versionRange = Range(match.range(at: 2), in: rawValue),
            let platform = BuildPlatform(rawValue: String(rawValue[nameRange]))
        else {
            logger.error("Unknown platform used for SDKVariant: \(rawValue)")
            return "Unknown.sdk"
        }

        return "\(platform.stylizedForDirectoryName)\(rawValue[versionRange]).sdk"
    }
}

private extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    func deletingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }
    
    func deletingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }
    
    func substringBefore(_ marker: String.Element) -> String {
        guard let index = firstIndex(of: marker) else { return self }
        return String(self[..<index])
    }
}
