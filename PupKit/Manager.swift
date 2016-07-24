//
//  Manager.swift
//  PupKit
//
//  (c) 2016 @toddheasley
//

import Foundation

public class Manager {
    public static let mediaPath: String = "media" // Suggested media directory
    public static let manifestURI: String = "index.json"
    public static let URIExtension: String = ".html"
    public private(set) var site: Site!
    public private(set) var path: String
    private let gitURIs: [String] = ["README", "README.md", "CNAME"]
    private static var bookmarkIconData: String = "iVBORw0KGgoAAAANSUhEUgAAAJgAAACYCAYAAAAYwiAhAAAAcElEQVR42u3BAQ0AAADCoPdPbQ8HFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/BhppwABkzBLogAAAABJRU5ErkJggg==" // Base64-encoded blank PNG
    
    public class func pitch(path: String) throws {
        if (Manager.exists(path: path)) {
            return
        }
        
        let pathComponents = path.split(string: "/").filter{ string in
            !string.isEmpty
        }
        let site: Site = Site()
        site.URI = "index\(Manager.URIExtension)"
        if let string = pathComponents.last, string.split(string: ".").count == 3 && string.hasSuffix(".github.io") {
            
            // Pre-populate Github Page URL
            site.URL = "https://\(string)"
        }
        do {
            let data: Data = try JSONSerialization.data(withJSONObject: site.dictionary, options: JSONSerialization.WritingOptions())
            
            // Write JSON manifest file
            let _ = try? data.write(to: URL(fileURLWithPath: "\(path)\(Manager.manifestURI)"), options: [.atomicWrite])
            
            // Create empty media directory
            let _ = try FileManager.default.createDirectory(atPath: "\(path)\(Manager.mediaPath)", withIntermediateDirectories: false, attributes: nil)
            
            // Write blank auxiliary files
            let _ = try? Data().write(to: URL(fileURLWithPath: "\(path)\(site.URI)"), options: [.atomicWrite])
            CSS().generate{ data in
                let _ = try? data.write(to: URL(fileURLWithPath: "\(path)\(HTML.stylesheetURI)"), options: [.atomicWrite])
            }
            if let data = Data(base64Encoded: Manager.bookmarkIconData, options: []) {
                let _ = try? data.write(to: URL(fileURLWithPath: "\(path)\(HTML.bookmarkIconURI)"), options: [.atomicWrite])
            }
        } catch {
            throw error
        }
    }
    
    public func build() throws {
        do {
            let data: Data = try JSONSerialization.data(withJSONObject: self.site.dictionary, options: JSONSerialization.WritingOptions())
            
            // Write JSON manifest file
            let _ = try? data.write(to: URL(fileURLWithPath: "\(self.path)\(Manager.manifestURI)"), options: [.atomicWrite])
            
            // Write HTML files
            HTML.generate(site: self.site) { URI, data in
                let _ = try? data.write(to: URL(fileURLWithPath: "\(self.path)\(URI)"), options: [.atomicWrite])
            }
        } catch {
            throw error
        }
    }
    
    public func clean() throws {
        
        // Assemble manifest of active files
        var manifest: [String] = [
            Manager.manifestURI,
            Manager.mediaPath,
            HTML.bookmarkIconURI,
            HTML.stylesheetURI
        ]
        if let executableURI = Bundle.main.executableURL?.lastPathComponent {
            manifest.append(executableURI)
        }
        manifest.append(contentsOf: self.gitURIs)
        manifest.append(contentsOf: self.site.manifest)
        
        let enumerator: FileManager.DirectoryEnumerator = FileManager.default.enumerator(atPath: self.path)!
        while let URI = enumerator.nextObject() as? String {
            if (!manifest.contains(URI) && !URI.hasPrefix(".")) {
                do {
                    
                    // Not found in manifest; move file to trash
                    try FileManager.default.trashItem(at: URL(fileURLWithPath: "\(self.path)\(URI)"), resultingItemURL: nil)
                } catch {
                    throw error
                }
            }
        }
    }
    
    public class func exists(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: "\(path)\(self.manifestURI)", isDirectory: nil)
    }
    
    public init(path: String) throws {
        self.path = path.components(separatedBy: Manager.manifestURI)[0]
        do {
            let data: Data = try Data(contentsOf: URL(fileURLWithPath: "\(path)\(Manager.manifestURI)"), options: [])
            let dictionary: [String: AnyObject] = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! [String: AnyObject]
            site = Site(dictionary: dictionary)
        } catch  {
            throw error
        }
    }
}
