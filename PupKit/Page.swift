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
    public var sections: Array<PageSection>
    
    public convenience init() {
        self.init(dictionary: [
            ArchivingKeys.index: true,
            ArchivingKeys.name: "",
            ArchivingKeys.URI: "",
            ArchivingKeys.sections: []
        ])
    }
    
    // MARK: Archiving
    public var manifest: Array<String> {
        get {
            var manifest = [String]()
            for section in self.sections {
                manifest.extend(section.manifest)
            }
            if (!self.URI.isEmpty) {
                manifest.append(self.URI)
            }
            return manifest
        }
    }
    
    public var dictionary: NSDictionary {
        get {
            var sections: Array<NSDictionary> = []
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
    }
    
    public required init(dictionary: NSDictionary) {
        self.index = dictionary[ArchivingKeys.index] as! Bool
        self.name = dictionary[ArchivingKeys.name] as! String
        self.URI = dictionary[ArchivingKeys.URI] as! String
        self.sections = []
        for section in dictionary[ArchivingKeys.sections] as! Array<NSDictionary> {
            self.sections.append(PageSection(dictionary: section as NSDictionary))
        }
    }
}

public enum PageSectionType: Int {
    case Basic = 0, Image = 1, Audio = 2, Video = 3
}

public class PageSection: Archiving {
    public var type: PageSectionType
    public var text: String
    public var URI: String
    
    public convenience init() {
        self.init(dictionary: [
            ArchivingKeys.type: ArchivingKeys.types[PageSectionType.Basic.rawValue],
            ArchivingKeys.text: "",
            ArchivingKeys.URI: ""
        ])
    }
    
    // Archiving
    public var manifest: Array<String> {
        get {
            var manifest = [String]()
            if (!self.URI.isEmpty) {
                manifest.append(self.URI)
            }
            return manifest
        }
    }
    
    public var dictionary: NSDictionary {
        get {
            return [
                ArchivingKeys.type: ArchivingKeys.types[self.type.rawValue],
                ArchivingKeys.text: self.text,
                ArchivingKeys.URI: self.URI
            ]
        }
    }
    
    required public init(dictionary: NSDictionary) {
        switch dictionary[ArchivingKeys.type] as! String {
        case ArchivingKeys.types[1]:
            self.type = PageSectionType.Image
        case ArchivingKeys.types[2]:
            self.type = PageSectionType.Audio
        case ArchivingKeys.types[3]:
            self.type = PageSectionType.Video
        default:
            self.type = PageSectionType.Basic
        }
        self.text = dictionary[ArchivingKeys.text] as! String
        self.URI = dictionary[ArchivingKeys.URI] as! String
    }
}
