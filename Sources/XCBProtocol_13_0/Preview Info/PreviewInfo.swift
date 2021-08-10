import Foundation
import MessagePack
import XCBProtocol

public struct PreviewInfo {
    public let sdkVariant: String // Called `sdkRoot` by Xcode. e.g. "macosx10.14"
    public let unknown: MessagePackValue
    public let buildVariant: String // Might be named wrong. e.g. "normal"
    public let architecture: String // e.g. "x86_64"
    public let compileCommandLine: [String] // e.g. ["/Applications/Xcode-11.3.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc", "-enforce-exclusivity=checked", ...]
    public let linkCommandLine: [String] // e.g. ["/Applications/Xcode-11.3.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang", "-target", ...]
    public let thunkSourceFile: String // e.g. "/Users/USER/Library/Developer/Xcode/DerivedData/PROJECT-hash/Build/Intermediates.noindex/Previews/TARGET_NAME/Intermediates.noindex/PROJECT_NAME.build/Debug-iphonesimulator/TARGET_NAME.build/Objects-normal/x86_64/SOURCE_FILE.__XCPREVIEW_THUNKSUFFIX__.preview-thunk.swift"
    public let thunkObjectFile: String // e.g. "/Users/USER/Library/Developer/Xcode/DerivedData/PROJECT-hash/Build/Intermediates.noindex/Previews/TARGET_NAME/Intermediates.noindex/PROJECT_NAME.build/Debug-iphonesimulator/TARGET_NAME.build/Objects-normal/x86_64/SOURCE_FILE.__XCPREVIEW_THUNKSUFFIX__.preview-thunk.o"
    public let thunkLibrary: String // e.g. "/Users/USER/Library/Developer/Xcode/DerivedData/PROJECT-hash/Build/Intermediates.noindex/Previews/TARGET_NAME/Intermediates.noindex/PROJECT_NAME.build/Debug-iphonesimulator/TARGET_NAME.build/Objects-normal/x86_64/SOURCE_FILE.__XCPREVIEW_THUNKSUFFIX__.preview-thunk.dylib"
    public let pifGUID: String
    
    public init(
        sdkVariant: String,
        buildVariant: String,
        architecture: String,
        compileCommandLine: [String],
        linkCommandLine: [String],
        thunkSourceFile: String,
        thunkObjectFile: String,
        thunkLibrary: String,
        pifGUID: String
    ) {
        self.sdkVariant = sdkVariant
        self.unknown = .nil
        self.buildVariant = buildVariant
        self.architecture = architecture
        self.compileCommandLine = compileCommandLine
        self.linkCommandLine = linkCommandLine
        self.thunkSourceFile = thunkSourceFile
        self.thunkObjectFile = thunkObjectFile
        self.thunkLibrary = thunkLibrary
        self.pifGUID = pifGUID
    }
}

// MARK: - Decoding

extension PreviewInfo: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 10 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }
        
        self.sdkVariant = try args.parseString(indexPath: indexPath + IndexPath(index: 0))
        self.unknown = try args.parseUnknown(indexPath: indexPath + IndexPath(index: 1))
        self.buildVariant = try args.parseString(indexPath: indexPath + IndexPath(index: 2))
        self.architecture = try args.parseString(indexPath: indexPath + IndexPath(index: 3))
        self.compileCommandLine = try args.parseStringArray(indexPath: indexPath + IndexPath(index: 4))
        self.linkCommandLine = try args.parseStringArray(indexPath: indexPath + IndexPath(index: 5))
        self.thunkSourceFile = try args.parseString(indexPath: indexPath + IndexPath(index: 6))
        self.thunkObjectFile = try args.parseString(indexPath: indexPath + IndexPath(index: 7))
        self.thunkLibrary = try args.parseString(indexPath: indexPath + IndexPath(index: 8))
        self.pifGUID = try args.parseString(indexPath: indexPath + IndexPath(index: 9))
    }
}

// MARK: - Encoding

extension PreviewInfo: EncodableRPCPayload {
    public func encode() -> [MessagePackValue] {
        return [
            .string(sdkVariant),
            unknown,
            .string(buildVariant),
            .string(architecture),
            .array(compileCommandLine.map(MessagePackValue.string)),
            .array(linkCommandLine.map(MessagePackValue.string)),
            .string(thunkSourceFile),
            .string(thunkObjectFile),
            .string(thunkLibrary),
            .string(pifGUID),
        ]
    }
}
