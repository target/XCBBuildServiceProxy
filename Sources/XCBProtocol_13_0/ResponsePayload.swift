import Foundation
import MessagePack
import XCBProtocol

public enum ResponsePayload {
    case ping(PingResponse)
    case bool(BoolResponse)
    case string(StringResponse)
    case error(ErrorResponse)
    
    case sessionCreated(SessionCreated)
    
    case buildCreated(BuildCreated)
    case buildOperationProgressUpdated(BuildOperationProgressUpdated)
    case buildOperationPreparationCompleted(BuildOperationPreparationCompleted)
    case buildOperationStarted(BuildOperationStarted)
    case buildOperationReportPathMap(BuildOperationReportPathMap)
    case buildOperationDiagnostic(BuildOperationDiagnosticEmitted)
    case buildOperationEnded(BuildOperationEnded)
    
    case planningOperationWillStart(PlanningOperationWillStart)
    case planningOperationDidFinish(PlanningOperationDidFinish)
    
    case buildOperationTargetUpToDate(BuildOperationTargetUpToDate)
    case buildOperationTargetStarted(BuildOperationTargetStarted)
    case buildOperationTargetEnded(BuildOperationTargetEnded)
    
    case buildOperationTaskUpToDate(BuildOperationTaskUpToDate)
    case buildOperationTaskStarted(BuildOperationTaskStarted)
    case buildOperationConsoleOutput(BuildOperationConsoleOutputEmitted)
    case buildOperationTaskEnded(BuildOperationTaskEnded)
    
    case indexingInfo(IndexingInfoResponse)
    
    case previewInfo(PreviewInfoResponse)
    
    case unknownResponse(UnknownResponse)
}

public struct UnknownResponse {
    public let values: [MessagePackValue]
}

// MARK: - Decoding

extension ResponsePayload: XCBProtocol.ResponsePayload {
    public static func unknownResponse(values: [MessagePackValue]) -> Self {
        return .unknownResponse(.init(values: values))
    }
    
    public static func errorResponse(_ message: String) -> Self {
        return .error(.init(message))
    }
    
    public init(values: [MessagePackValue], indexPath: IndexPath) throws {
        let name = try values.parseString(indexPath: indexPath + IndexPath(index: 0))
        let bodyIndexPath = indexPath + IndexPath(index: 1)
        
        switch name {
        case "PING": self = .ping(try values.parseObject(indexPath: bodyIndexPath))
        case "BOOL": self = .bool(try values.parseObject(indexPath: bodyIndexPath))
        case "STRING": self = .string(try values.parseObject(indexPath: bodyIndexPath))
        case "ERROR": self = .error(try values.parseObject(indexPath: bodyIndexPath))
        case "SESSION_CREATED": self = .sessionCreated(try values.parseObject(indexPath: bodyIndexPath))
        case "BUILD_CREATED": self = .buildCreated(try values.parseObject(indexPath: bodyIndexPath))
        case "BUILD_PROGRESS_UPDATED": self = .buildOperationProgressUpdated(try values.parseObject(indexPath: bodyIndexPath))
        case "BUILD_PREPARATION_COMPLETED": self = .buildOperationPreparationCompleted(try values.parseObject(indexPath: bodyIndexPath))
        case "BUILD_OPERATION_STARTED": self = .buildOperationStarted(try values.parseObject(indexPath: bodyIndexPath))
        case "BUILD_OPERATION_REPORT_PATH_MAP": self = .buildOperationReportPathMap(try values.parseObject(indexPath: bodyIndexPath))
        case "BUILD_DIAGNOSTIC_EMITTED": self = .buildOperationDiagnostic(try values.parseObject(indexPath: bodyIndexPath))
        case "BUILD_OPERATION_ENDED": self = .buildOperationEnded(try values.parseObject(indexPath: bodyIndexPath))
        case "PLANNING_OPERATION_WILL_START": self = .planningOperationWillStart(try values.parseObject(indexPath: bodyIndexPath))
        case "PLANNING_OPERATION_FINISHED": self = .planningOperationDidFinish(try values.parseObject(indexPath: bodyIndexPath))
        case "BUILD_TARGET_UPTODATE": self = .buildOperationTargetUpToDate(try values.parseObject(indexPath: bodyIndexPath))
        case "BUILD_TARGET_STARTED":
            
            let data = try values.parseBinary(indexPath: bodyIndexPath)
            self = .buildOperationTargetStarted(try JSONDecoder().decode(BuildOperationTargetStarted.self, from: data))
        case "BUILD_TARGET_ENDED": self = .buildOperationTargetEnded(try values.parseObject(indexPath: bodyIndexPath))
        case "BUILD_TASK_UPTODATE": self = .buildOperationTaskUpToDate(try values.parseObject(indexPath: bodyIndexPath))
        case "BUILD_TASK_STARTED": self = .buildOperationTaskStarted(try values.parseObject(indexPath: bodyIndexPath))
        case "BUILD_CONSOLE_OUTPUT_EMITTED": self = .buildOperationConsoleOutput(try values.parseObject(indexPath: bodyIndexPath))
        case "BUILD_TASK_ENDED": self = .buildOperationTaskEnded(try values.parseObject(indexPath: bodyIndexPath))
        case "INDEXING_INFO_RECEIVED": self = .indexingInfo(try values.parseObject(indexPath: bodyIndexPath))
        case "PREVIEW_INFO_RECEIVED": self = .previewInfo(try values.parseObject(indexPath: bodyIndexPath))
            
        default: self = .unknownResponse(.init(values: values))
        }
    }
    
    private var name: String {
        switch self {
        case .ping: return "PING"
        case .bool: return "BOOL"
        case .string: return "STRING"
        case .error: return "ERROR"
        case .sessionCreated: return "SESSION_CREATED"
        case .buildCreated: return "BUILD_CREATED"
        case .buildOperationProgressUpdated: return "BUILD_PROGRESS_UPDATED"
        case .buildOperationPreparationCompleted: return "BUILD_PREPARATION_COMPLETED"
        case .buildOperationStarted: return "BUILD_OPERATION_STARTED"
        case .buildOperationReportPathMap: return "BUILD_OPERATION_REPORT_PATH_MAP"
        case .buildOperationDiagnostic: return "BUILD_DIAGNOSTIC_EMITTED"
        case .buildOperationEnded: return "BUILD_OPERATION_ENDED"
        case .planningOperationWillStart: return "PLANNING_OPERATION_WILL_START"
        case .planningOperationDidFinish: return "PLANNING_OPERATION_FINISHED"
        case .buildOperationTargetUpToDate: return "BUILD_TARGET_UPTODATE"
        case .buildOperationTargetStarted: return "BUILD_TARGET_STARTED"
        case .buildOperationTargetEnded: return "BUILD_TARGET_ENDED"
        case .buildOperationTaskUpToDate: return "BUILD_TASK_UPTODATE"
        case .buildOperationTaskStarted: return "BUILD_TASK_STARTED"
        case .buildOperationConsoleOutput: return "BUILD_CONSOLE_OUTPUT_EMITTED"
        case .buildOperationTaskEnded: return "BUILD_TASK_ENDED"
        case .indexingInfo: return "INDEXING_INFO_RECEIVED"
        case .previewInfo: return "PREVIEW_INFO_RECEIVED"
            
        case .unknownResponse: preconditionFailure("Tried to get name of UnknownResponse")
        }
    }
    
    private var message: CustomEncodableRPCPayload {
        switch self {
        case let .ping(message): return message
        case let .bool(message): return message
        case let .string(message): return message
        case let .error(message): return message
        case let .sessionCreated(message): return message
        case let .buildCreated(message): return message
        case let .buildOperationProgressUpdated(message): return message
        case let .buildOperationPreparationCompleted(message): return message
        case let .buildOperationStarted(message): return message
        case let .buildOperationReportPathMap(message): return message
        case let .buildOperationDiagnostic(message): return message
        case let .buildOperationEnded(message): return message
        case let .planningOperationWillStart(message): return message
        case let .planningOperationDidFinish(message): return message
        case let .buildOperationTargetUpToDate(message): return message
        case let .buildOperationTargetStarted(message): return message
        case let .buildOperationTargetEnded(message): return message
        case let .buildOperationTaskUpToDate(message): return message
        case let .buildOperationTaskStarted(message): return message
        case let .buildOperationConsoleOutput(message): return message
        case let .buildOperationTaskEnded(message): return message
        case let .indexingInfo(message): return message
        case let .previewInfo(message): return message
            
        case .unknownResponse: preconditionFailure("Tried to get message of UnknownResponse")
        }
    }
    
    public func encode() -> [MessagePackValue] {
        if case let .unknownResponse(message) = self {
            return message.values
        }
        
        return [.string(name), message.encode()]
    }
}
