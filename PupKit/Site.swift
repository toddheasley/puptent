//
//  Site.swift
//  PupKit
//
//  (c) 2015 @toddheasley
//

import Foundation

public class Site: Archiving {
    public var name: String
    public var URI: String
    public var twitterName: String
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
            ArchivingKeys.twitterName: "",
            ArchivingKeys.pages: []
        ])
    }
    
    // MARK: Archiving
    public var manifest: [String] {
        var manifest = [String]()
        for page in self.pages {
            manifest.appendContentsOf(page.manifest)
        }
        if (!URI.isEmpty) {
            manifest.append(URI)
        }
        return manifest
    }
    
    public var dictionary: [String: AnyObject] {
        var pages: [AnyObject] = []
        for page in self.pages {
            pages.append(page.dictionary)
        }
        return [
            ArchivingKeys.name: name,
            ArchivingKeys.URI: URI,
            ArchivingKeys.twitterName: twitterName,
            ArchivingKeys.pages: pages
        ]
    }
    
    public required init(dictionary: [String: AnyObject]) {
        name = dictionary[ArchivingKeys.name] as! String
        URI = dictionary[ArchivingKeys.URI] as! String
        twitterName = dictionary[ArchivingKeys.twitterName] as! String
        pages = []
        for page in dictionary[ArchivingKeys.pages] as! [AnyObject] {
            pages.append(Page(dictionary: page as! [String: AnyObject]))
        }
    }
}
