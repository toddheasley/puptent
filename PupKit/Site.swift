import Foundation

public struct Site: Resource, Codable {
    public var name: String = ""
    public var pages: [Page] = []
    public var twitter: String?
    public var url: URL?
    
    public var indexedPages: [Page] {
        return pages.filter{ page in
            return page.index
        }
    }
    
    public init() {
        
    }
    
    // MARK: Resource
    public var uri: String = "index.html"
    
    var manifest: [String] {
        var manifest: [String] = []
        for page in pages {
            manifest.append(contentsOf: page.manifest)
        }
        if !uri.isEmpty {
            manifest.append(uri)
        }
        return manifest
    }
}
