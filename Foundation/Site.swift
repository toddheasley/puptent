//
//  Site.swift
//  PupTent
//
//  (c) 2014 @toddheasley
//

import Foundation

public class Site: Archiving {
    public var name: String
    public var URI: String
    public var twitterName: String
    public var domain: String
    public var pages: Array<Page>
    public var indexedPages: Array<Page> {
        get {
            var pages: Array<Page> = []
            for page in self.pages {
                if (page.index) {
                    pages.append(page)
                }
            }
            return pages
        }
    }
    
    public convenience init() {
        self.init(dictionary: [
            ArchivingKeys.name: "",
            ArchivingKeys.URI: "",
            ArchivingKeys.twitterName: "",
            ArchivingKeys.domain: "",
            ArchivingKeys.pages: [
                Page().dictionary
            ]
        ])
    }
    
    // Archiving
    public var manifest: Array<String> {
        get {
            var manifest = [String]()
            for page in self.pages {
                manifest.extend(page.manifest)
            }
            if (!self.URI.isEmpty) {
                manifest.append(self.URI)
            }
            return manifest
        }
    }
    
    public var dictionary: NSDictionary {
        get {
            var pages: Array<NSDictionary> = []
            for page in self.pages {
                pages.append(page.dictionary)
            }
            return [
                ArchivingKeys.name: self.name,
                ArchivingKeys.URI: self.URI,
                ArchivingKeys.twitterName: self.twitterName,
                ArchivingKeys.domain: self.domain,
                ArchivingKeys.pages: pages
            ]
        }
    }
    
    public required init(dictionary: NSDictionary) {
        self.name = dictionary[ArchivingKeys.name] as String
        self.URI = dictionary[ArchivingKeys.URI] as String
        self.twitterName = dictionary[ArchivingKeys.twitterName] as String
        self.domain = dictionary[ArchivingKeys.domain] as String
        self.pages = []
        for page in dictionary[ArchivingKeys.pages] as Array<NSDictionary> {
            self.pages.append(Page(dictionary: page as NSDictionary))
        }
    }
}