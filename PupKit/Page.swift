//
//  Page.swift
//  PupKit
//
//  (c) 2015 @toddheasley
//

import Foundation

public class Page: Archiving {
    public var index: Bool
    public var name: String
    public var URI: String
    public var sections: [PageSection]
    
    public convenience init() {
        self.init(dictionary: [
            ArchivingKeys.index: true,
            ArchivingKeys.name: "",
            ArchivingKeys.URI: "",
            ArchivingKeys.sections: []
        ])
    }
    
    // MARK: Archiving
    public var manifest: [String] {
        var manifest = [String]()
        for section in self.sections {
            manifest.appendContentsOf(section.manifest)
        }
        if (!self.URI.isEmpty) {
            manifest.append(self.URI)
        }
        return manifest
    }
    
    public var dictionary: [String: AnyObject] {
        var sections: [AnyObject] = []
        for section in self.sections {
            sections.append(section.dictionary)
        }
        return [
            ArchivingKeys.index: self.index,
            ArchivingKeys.name: self.name,
            ArchivingKeys.URI: self.URI,
            ArchivingKeys.sections: sections
        ]
    }
    
    public required init(dictionary: [String: AnyObject]) {
        self.index = dictionary[ArchivingKeys.index] as! Bool
        self.name = dictionary[ArchivingKeys.name] as! String
        self.URI = dictionary[ArchivingKeys.URI] as! String
        self.sections = []
        for section in dictionary[ArchivingKeys.sections] as! [AnyObject] {
            self.sections.append(PageSection(dictionary: section as! [String: AnyObject]))
        }
    }
}

public class PageSection: Archiving {
    public enum Type: String {
        case Basic = "basic"
        case Image = "image"
        case Audio = "audio"
        case Video = "video"
    }
    
    public var type: Type
    public var text: String
    public var URI: String
    
    public convenience init() {
        self.init(dictionary: [
            ArchivingKeys.type: Type.Basic.rawValue,
            ArchivingKeys.text: "",
            ArchivingKeys.URI: ""
        ])
    }
    
    // Archiving
    public var manifest: [String] {
        var manifest = [String]()
        if (!self.URI.isEmpty) {
            manifest.append(self.URI)
        }
        return manifest
    }
    
    public var dictionary: [String: AnyObject] {
        return [
            ArchivingKeys.type: self.type.rawValue,
            ArchivingKeys.text: self.text,
            ArchivingKeys.URI: self.URI
        ]
    }
    
    required public init(dictionary: [String: AnyObject]) {
        self.type = Type(rawValue: dictionary[ArchivingKeys.type] as! String)!
        self.text = dictionary[ArchivingKeys.text] as! String
        self.URI = dictionary[ArchivingKeys.URI] as! String
    }
}
