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
    public var baseURL: String
    public var twitterName: String
    public var pages: [Page]
    
    public var indexedPages: [Page] {
        return self.pages.filter{ page in
            return page.index
        }
    }
    
    public convenience init() {
        self.init(dictionary: [
            ArchivingKeys.name: "",
            ArchivingKeys.URI: "",
            ArchivingKeys.baseURL: "",
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
        if (!self.URI.isEmpty) {
            manifest.append(self.URI)
        }
        return manifest
    }
    
    public var dictionary: [String: AnyObject] {
        var pages: [AnyObject] = []
        for page in self.pages {
            pages.append(page.dictionary)
        }
        return [
            ArchivingKeys.name: self.name,
            ArchivingKeys.URI: self.URI,
            ArchivingKeys.baseURL: self.baseURL,
            ArchivingKeys.twitterName: self.twitterName,
            ArchivingKeys.pages: pages
        ]
    }
    
    public required init(dictionary: [String: AnyObject]) {
        self.name = dictionary[ArchivingKeys.name] as! String
        self.URI = dictionary[ArchivingKeys.URI] as! String
        self.baseURL = dictionary[ArchivingKeys.baseURL] as! String
        self.twitterName = dictionary[ArchivingKeys.twitterName] as! String
        self.pages = []
        for page in dictionary[ArchivingKeys.pages] as! [AnyObject] {
            self.pages.append(Page(dictionary: page as! [String: AnyObject]))
        }
    }
}
