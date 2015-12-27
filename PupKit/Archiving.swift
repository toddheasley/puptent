//
//  Archiving.swift
//  PupKit
//
//  (c) 2015 @toddheasley
//

import Foundation

protocol Archiving {
    var manifest: [String] {
        get
    }
    
    var dictionary: [String: AnyObject] {
        get
    }
    
    init(dictionary: [String: AnyObject])
}

struct ArchivingKeys {
    static let name = "name"
    static let URI = "URI"
    static let twitter = "twitter"
    static let pages = "pages"
    static let index = "index"
    static let body = "body"
}
