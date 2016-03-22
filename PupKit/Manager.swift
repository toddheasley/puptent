//
//  Manager.swift
//  PupKit
//
//  (c) 2015 @toddheasley
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
        if (Manager.exists(path)) {
            return
        }
        
        let pathComponents = path.split("/").filter{ string in
            !string.isEmpty
        }
        let site: Site = Site()
        site.URI = "index\(Manager.URIExtension)"
        if let string = pathComponents.last where string.split(".").count == 3 && string.hasSuffix(".github.io") {
            
            // Pre-populate Github Page URL
            site.URL = "https://\(string)"
        }
        do {
            let data: NSData = try NSJSONSerialization.dataWithJSONObject(site.dictionary, options: NSJSONWritingOptions())
            
            // Write JSON manifest file
            data.writeToFile("\(path)\(Manager.manifestURI)", atomically: true)
            
            // Create empty media directory
            try NSFileManager.defaultManager().createDirectoryAtPath("\(path)\(Manager.mediaPath)", withIntermediateDirectories: false, attributes: nil)
            
            // Write blank auxiliary files
            NSData().writeToFile("\(path)\(site.URI)", atomically: true)
            CSS().generate{ data in
                data.writeToFile("\(path)\(HTML.stylesheetURI)", atomically: true)
            }
            if let data = NSData(base64EncodedString: Manager.bookmarkIconData, options: []) {
                data.writeToFile("\(path)\(HTML.bookmarkIconURI)", atomically: true)
            }
        } catch {
            throw error
        }
    }
    
    public func build() throws {
        do {
            let data: NSData = try NSJSONSerialization.dataWithJSONObject(self.site.dictionary, options: NSJSONWritingOptions())
            
            // Write JSON manifest file
            data.writeToFile("\(self.path)\(Manager.manifestURI)", atomically: true)
            
            // Write HTML files
            HTML.generate(self.site) { URI, data in
                data.writeToFile("\(self.path)\(URI)", atomically: true)
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
        if let executableURI = NSBundle.mainBundle().executableURL?.lastPathComponent {
            manifest.append(executableURI)
        }
        manifest.appendContentsOf(self.gitURIs)
        manifest.appendContentsOf(self.site.manifest)
        
        let enumerator: NSDirectoryEnumerator = NSFileManager.defaultManager().enumeratorAtPath(self.path)!
        while let URI = enumerator.nextObject() as? String {
            if (!manifest.contains(URI) && !URI.hasPrefix(".")) {
                do {
                    
                    // Not found in manifest; move file to trash
                    try NSFileManager.defaultManager().trashItemAtURL(NSURL.fileURLWithPath("\(self.path)\(URI)"), resultingItemURL: nil)
                } catch {
                    throw error
                }
            }
        }
    }
    
    public class func exists(path: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath("\(path)\(self.manifestURI)", isDirectory: nil)
    }
    
    public init(path: String) throws {
        self.path = path.componentsSeparatedByString(Manager.manifestURI)[0]
        do {
            let data: NSData = try NSData(contentsOfURL: NSURL.fileURLWithPath("\(path)\(Manager.manifestURI)"), options: [])
            let dictionary: [String: AnyObject] = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! [String: AnyObject]
            site = Site(dictionary: dictionary)
        } catch  {
            throw error
        }
    }
}
