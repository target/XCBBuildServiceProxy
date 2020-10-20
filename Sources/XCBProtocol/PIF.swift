import Foundation

public struct WorkspacePIF: Decodable {
    public let guid: String
    public let path: String
    public let projects: [String]
}

public enum BuildSetting {
    case string(String)
    case array([String])
}

extension BuildSetting: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let array = try? container.decode([String].self) {
            self = .array(array)
        } else {
            self = .string(try container.decode(String.self))
        }
    }
}

public struct PIFBuildConfiguration: Decodable {
    public let name: String
    public let buildSettings: [String: BuildSetting]
}

public struct ProjectPIF: Decodable {
    private let projectName: String?
    public let path: String
    public let projectDirectory: String
    private let projectIsPackage: String?
    public let guid: String
    public let buildConfigurations: [PIFBuildConfiguration]
    public let targets: [String]
}

extension ProjectPIF {
    public var name: String {
        // "/Path/To/Project.xcodeproj" -> "Project"
        projectName ?? ((path as NSString).lastPathComponent as NSString).deletingPathExtension
    }
    
    public var isPackage: Bool { projectIsPackage?.lowercased() == "true" }
}

public struct TargetPIF: Decodable {
    public let name: String
    public let guid: String
    public let productTypeIdentifier: String?
    public let buildConfigurations: [PIFBuildConfiguration]
}
