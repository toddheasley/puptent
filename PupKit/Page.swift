import Foundation

public struct Page: Resource, Codable {
    public var name: String = ""
    public var body: HTML = ""
    public var index: Bool = true
    
    public init() {
        
    }
    
    // MARK: Resource
    public var uri: String = ""
    
    var manifest: [String] {
        var manifest: [String] = body.manifest
        if !uri.isEmpty {
            manifest.append(uri)
        }
        return manifest
    }
}
