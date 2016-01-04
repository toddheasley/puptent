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
    public var body: String
    
    public convenience init() {
        self.init(dictionary: [
            ArchivingKeys.index: true,
            ArchivingKeys.name: "",
            ArchivingKeys.URI: "",
            ArchivingKeys.body: ""
        ])
    }
    
    // MARK: Archiving
    public var manifest: [String] {
        var manifest = body.manifest
        if (!URI.isEmpty) {
            manifest.append(URI)
        }
        return manifest
    }
    
    public var dictionary: [String: AnyObject] {
        return [
            ArchivingKeys.index: index,
            ArchivingKeys.name: name,
            ArchivingKeys.URI: URI,
            ArchivingKeys.body: body
        ]
    }
    
    public required init(dictionary: [String: AnyObject]) {
        index = dictionary[ArchivingKeys.index] as! Bool
        name = dictionary[ArchivingKeys.name] as! String
        URI = dictionary[ArchivingKeys.URI] as! String
        body = dictionary[ArchivingKeys.body] as! String
    }
}
