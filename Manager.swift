//
//  Manager.swift
//  PupTent
//
//  (c) 2014 @toddheasley
//

import Foundation

public class Manager: HTMLDelegate {
    public class var bookmarkIconURI: String {
        get {
            return "apple-touch-icon.png"
        }
    }
    public class var stylesheetURI: String {
        get {
            return "default.css"
        }
    }
    public class var mediaPath: String {
        get {
            return "media" // Suggested media directory
        }
    }
    public class var manifestURI: String {
        get {
            return "index.json"
        }
    }
    public var site: Site!
    public var path: String {
        get {
            return self._path
        }
    }
    
    public init?(path: String, error: NSErrorPointer) {
        self._path = path.componentsSeparatedByString(Manager.manifestURI)[0]
        if let data: NSData = NSData(contentsOfURL: NSURL(fileURLWithPath: path + Manager.manifestURI)!, options: nil, error: &error.memory) {
            if let dictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error.memory) as? NSDictionary {
                self.site = Site(dictionary: dictionary)
                return
            }
        }
        return nil
    }
    
    public class func exists(path: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(path + self.manifestURI, isDirectory: nil)
    }
    
    public class func pitch(path: String) -> NSError? {
        var error: NSError?
        var site: Site = Site()
        site.URI = "index.html"
        if let data: NSData = NSJSONSerialization.dataWithJSONObject(site.dictionary, options: NSJSONWritingOptions.PrettyPrinted, error: &error) {
            
            // Write JSON manifest file
            data.writeToFile(path + Manager.manifestURI, atomically: true)
            
            // Create empty media directory
            NSFileManager.defaultManager().createDirectoryAtPath(path + Manager.mediaPath, withIntermediateDirectories: false, attributes: nil, error: &error)
            
            // Write blank auxiliary files
            NSData().writeToFile(path + site.URI, atomically: true)
            NSData().writeToFile(path + Manager.stylesheetURI, atomically: true)
            if let data = NSData(base64EncodedString: Manager.bookmarkIconData, options: nil) {
                data.writeToFile(path + Manager.bookmarkIconURI, atomically: true)
            }
        }
        return error
    }
    
    public func build() -> NSError? {
        return HTML.generate(self.site, bookmarkIconURI: Manager.bookmarkIconURI, stylesheetURI: Manager.stylesheetURI, delegate: self)
    }
    
    public func clean() -> NSError? {
        var error: NSError?
        
        // Assemble manifest of active files
        var manifest: Array<String> = [
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
        
        let enumerator: NSDirectoryEnumerator = NSFileManager.defaultManager().enumeratorAtPath(self._path)!
        while let URI = enumerator.nextObject() as? String {
            if (!contains(manifest, URI) || URI.hasPrefix(".")) {
                
                // Not found in manifest; move file to trash
                NSFileManager.defaultManager().trashItemAtURL(NSURL(fileURLWithPath: self._path + URI)!, resultingItemURL: nil, error: &error)
            }
        }
        return error
    }
    
    private class var bookmarkIconData: String {
        get {
            return "iVBORw0KGgoAAAANSUhEUgAAAJgAAACYCAYAAAAYwiAhAAAAcElEQVR42u3BAQ0AAADCoPdPbQ8HFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/BhppwABkzBLogAAAABJRU5ErkJggg==" // Base64-encoded blank PNG
        }
    }
    private let gitURIs: Array<String> = ["README", "README.md", "CNAME"]
    private var _path: String
    
    // HTMLDelegate
    public func handleHTML(HTML: String, URI: String) -> NSError? {
        var error: NSError?
        HTML.dataUsingEncoding(NSUTF8StringEncoding)!.writeToFile(self.path + URI, options: NSDataWritingOptions.AtomicWrite, error: &error)
        return error
    }
}
