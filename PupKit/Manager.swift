//
//  Manager.swift
//  PupKit
//
//  (c) 2015 @toddheasley
//

import Foundation

typealias PupKit = Manager

public class Manager {
    public static let bookmarkIconURI: String = "apple-touch-icon.png"
    public static let stylesheetURI: String = "default.css"
    public static let mediaPath: String = "media" // Suggested media directory
    public static let manifestURI: String = "index.json"
    public static let URIExtension: String = ".html"
    public var site: Site!
    public private(set) var path: String
    private let gitURIs: [String] = ["README", "README.md", "CNAME"]
    private static var bookmarkIconData: String {
        return "iVBORw0KGgoAAAANSUhEUgAAAJgAAACYCAYAAAAYwiAhAAAAcElEQVR42u3BAQ0AAADCoPdPbQ8HFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/BhppwABkzBLogAAAABJRU5ErkJggg==" // Base64-encoded blank PNG
    }
    
    public init(path: String) throws {
        self.path = path.componentsSeparatedByString(Manager.manifestURI)[0]
        do {
            let data: NSData = try NSData(contentsOfURL: NSURL.fileURLWithPath("\(path)\(Manager.manifestURI)"), options: [])
            let dictionary: [String: AnyObject] = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! [String: AnyObject]
            self.site = Site(dictionary: dictionary)
        } catch  {
            throw error
        }
    }
    
    public class func exists(path: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(path + self.manifestURI, isDirectory: nil)
    }
    
    public class func pitch(path: String) throws {
        if (Manager.exists(path)) {
            return
        }
        
        let site: Site = Site()
        site.URI = "index\(Manager.URIExtension)"
        do {
            let data: NSData = try NSJSONSerialization.dataWithJSONObject(site.dictionary, options: NSJSONWritingOptions())
            
            // Write JSON manifest file
            data.writeToFile("\(path)\(Manager.manifestURI)", atomically: true)
            
            // Create empty media directory
            try NSFileManager.defaultManager().createDirectoryAtPath("\(path)\(Manager.mediaPath)", withIntermediateDirectories: false, attributes: nil)
            
            // Write blank auxiliary files
            NSData().writeToFile("\(path)\(site.URI)", atomically: true)
            NSData().writeToFile("\(path)\(Manager.stylesheetURI)", atomically: true)
            if let data = NSData(base64EncodedString: Manager.bookmarkIconData, options: []) {
                data.writeToFile(path + Manager.bookmarkIconURI, atomically: true)
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
        } catch {
            throw error
        }
    }
    
    public func clean() throws {
        
        // Assemble manifest of active files
        var manifest: [String] = [
            Manager.manifestURI,
            Manager.bookmarkIconURI,
            Manager.stylesheetURI,
            Manager.mediaPath
        ]
        if let executableURI = NSBundle.mainBundle().executablePath?.lastPathComponent {
            manifest.append(executableURI)
        }
        manifest.extend(self.gitURIs)
        manifest.extend(self.site.manifest)
        
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
}
