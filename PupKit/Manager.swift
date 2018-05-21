import Foundation

public struct Manager {
    public static let manifest: String = "index.json"
    public static let media: String = "media" // Suggested media directory
    public static let bookmarkIcon: Data = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAJgAAACYCAYAAAAYwiAhAAAAcElEQVR42u3BAQ0AAADCoPdPbQ8HFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/BhppwABkzBLogAAAABJRU5ErkJggg==")! // Blank PNG
    public private(set) var path: String
    public var site: Site!
    
    public static func pitch(path: String) throws {
        guard !Manager.exists(path: path) else {
            return
        }
        let pathComponents = path.split(string: "/").filter{ string in
            return !string.isEmpty
        }
        var site: Site = Site()
        if let string: String = pathComponents.last, string.split(string: ".").count == 3 && string.hasSuffix(".github.io") {
            site.url = URL(string: "https://\(string)") // Pre-populate Github Page URL
        }
        let data: Data = try JSONEncoder().encode(site)
        try data.write(to: URL(fileURLWithPath: "\(path)\(Manager.manifest)"), options: .atomicWrite)
        
        // Make empty media directory
        try FileManager.default.createDirectory(atPath: "\(path)\(Manager.media)", withIntermediateDirectories: false, attributes: nil)
        
        // Write blank auxiliary files
        try Data().write(to: URL(fileURLWithPath: "\(path)\(site.uri)"), options: .atomicWrite)
        CSS().generate{ data in
            try? data.write(to: URL(fileURLWithPath: "\(path)\(HTML.stylesheet)"), options: .atomicWrite)
        }
        try Manager.bookmarkIcon.write(to: URL(fileURLWithPath: "\(path)\(HTML.bookmarkIcon)"), options: .atomicWrite)
    }
    
    public func build() throws {
        let data: Data = try JSONEncoder().encode(site)
        try data.write(to: URL(fileURLWithPath: "\(path)\(Manager.manifest)"), options: .atomicWrite)
        HTML.generate(site: site) { uri, data in
            try? data.write(to: URL(fileURLWithPath: "\(self.path)\(uri)"), options: .atomicWrite)
        }
    }
    
    public func clean() throws {
        
        // Assemble manifest of active files
        var manifest: [String] = [
            Manager.manifest,
            Manager.media,
            HTML.bookmarkIcon,
            HTML.stylesheet
        ]
        if let executableURI = Bundle.main.executableURL?.lastPathComponent {
            manifest.append(executableURI)
        }
        manifest.append(contentsOf: ["README", "README.md", "CNAME"])
        manifest.append(contentsOf: site.manifest)
        
        let enumerator: FileManager.DirectoryEnumerator = FileManager.default.enumerator(atPath: path)!
        while let uri: String = enumerator.nextObject() as? String {
            if !manifest.contains(uri) && !uri.hasPrefix(".") {
                
                // Not found in manifest; move file to trash
                try FileManager.default.trashItem(at: URL(fileURLWithPath: "\(self.path)\(uri)"), resultingItemURL: nil)
            }
        }
    }
    
    public static func exists(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: "\(path)\(self.manifest)", isDirectory: nil)
    }
    
    public init(path: String) throws {
        self.path = path.components(separatedBy: Manager.manifest)[0]
        let data: Data = try Data(contentsOf: URL(fileURLWithPath: "\(path)\(Manager.manifest)"), options: [])
        self.site = try JSONDecoder().decode(Site.self, from: data)
    }
}
