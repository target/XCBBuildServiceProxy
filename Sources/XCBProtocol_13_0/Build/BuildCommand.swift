import Foundation
import MessagePack
import XCBProtocol

public struct BuildCommand: Decodable {
    
    public let command: Command
    let enableIndexBuildArena: Bool
    let targets: String
    
    public enum Command: String, Decodable {
        case build
        case prepareForIndexing
        case migrate
        case generateAssemblyCode
        case generatePreprocessedFile
        case cleanBuildFolder
        case preview
    }
}
