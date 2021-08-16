import Foundation
import MessagePack
import XCBProtocol

public struct BuildOperationDiagnosticEmitted {
    public let kind: BuildOperationDiagnosticKind
    public let location: BuildOperationDiagnosticLocation
    public let message: String
    public let component: BuildOperationDiagnosticComponent
    public let unknown1: String // e.g. "default"
    public let appendToOutputStream: Bool // If `true`, it's attached to the output instead of showing as a new entry
    public let unknown2: MessagePackValue // Might be `fixIts`
    public let unknown3: MessagePackValue // Might be `childDiagnostics`
    public let unknown4: MessagePackValue
    
    public init(
        kind: BuildOperationDiagnosticKind,
        location: BuildOperationDiagnosticLocation,
        message: String,
        component: BuildOperationDiagnosticComponent,
        unknown: String,
        appendToOutputStream: Bool
    ) {
        self.kind = kind
        self.location = location
        self.message = message
        self.component = component
        self.unknown1 = unknown
        self.appendToOutputStream = appendToOutputStream
        self.unknown2 = .array([])
        self.unknown3 = .array([])
        self.unknown4 = .array([])
    }
}

// MARK: - ResponsePayloadConvertible

extension BuildOperationDiagnosticEmitted: ResponsePayloadConvertible {
    public func toResponsePayload() -> ResponsePayload { .buildOperationDiagnostic(self) }
}

// MARK: - Decoding

extension BuildOperationDiagnosticEmitted: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 9 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
            
        self.kind = try args.parseObject(indexPath: indexPath + IndexPath(index: 0))
        self.location = try args.parseObject(indexPath: indexPath + IndexPath(index: 1))
        self.message = try args.parseString(indexPath: indexPath + IndexPath(index: 2))
        self.component = try args.parseObject(indexPath: indexPath + IndexPath(index: 3))
        self.unknown1 = try args.parseString(indexPath: indexPath + IndexPath(index: 4))
        self.appendToOutputStream = try args.parseBool(indexPath: indexPath + IndexPath(index: 5))
        self.unknown2 = try args.parseUnknown(indexPath: indexPath + IndexPath(index: 6))
        self.unknown3 = try args.parseUnknown(indexPath: indexPath + IndexPath(index: 7))
        self.unknown4 = try args.parseUnknown(indexPath: indexPath + IndexPath(index: 8))
    }
}

// MARK: - Encoding

extension BuildOperationDiagnosticEmitted: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [
            .int64(kind.rawValue),
            .array(location.encode()),
            .string(message),
            .array(component.encode()),
            .string(unknown1),
            .bool(appendToOutputStream),
            unknown2,
            unknown3,
            unknown4,
        ]
    }
}
