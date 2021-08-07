import Foundation
import MessagePack
import XCBProtocol

public struct BuildCommand: Decodable {
    
    let command: Command
    let enableIndexBuildArena: Bool
    let targets: String
    
    enum Command: String, Decodable {
        case build
        case prepareForIndexing
        case migrate
        case generateAssemblyCode
        case generatePreprocessedFile
        case cleanBuildFolder
        case preview
    }
}
