//
//  Site.swift
//  PupKit
//
//  (c) 2016 @toddheasley
//

import Foundation

public class Site: Archiving {
    public var name: String
    public var URI: String
    public var URL: String = ""
    public var twitter: String
    public var pages: [Page]
    
    public var indexedPages: [Page] {
        return pages.filter{ page in
            return page.index
        }
    }
    
    public convenience init() {
        self.init(dictionary: [
            ArchivingKeys.name: "",
            ArchivingKeys.URI: "",
            ArchivingKeys.URL: "",
            ArchivingKeys.twitter: "",
            ArchivingKeys.pages: []
        ])
    }
    
    // MARK: Archiving
    public var manifest: [String] {
        var manifest = [String]()
        for page in pages {
            manifest.append(contentsOf: page.manifest)
        }
        if !URI.isEmpty {
            manifest.append(URI)
        }
        return manifest
    }
    
    public var dictionary: [String: Any] {
        var pages: [Any] = []
        for page in self.pages {
            pages.append(page.dictionary)
        }
        return [
            ArchivingKeys.name: name,
            ArchivingKeys.URI: URI,
            ArchivingKeys.URL: URL,
            ArchivingKeys.twitter: twitter,
            ArchivingKeys.pages: pages
        ]
    }
    
    public required init(dictionary: [String: Any]) {
        name = dictionary[ArchivingKeys.name] as! String
        URI = dictionary[ArchivingKeys.URI] as! String
        if let URL = dictionary[ArchivingKeys.URL] as? String {
            self.URL = URL
        }
        twitter = dictionary[ArchivingKeys.twitter] as! String
        pages = []
        for page in dictionary[ArchivingKeys.pages] as! [AnyObject] {
            pages.append(Page(dictionary: page as! [String: AnyObject]))
        }
    }
}
