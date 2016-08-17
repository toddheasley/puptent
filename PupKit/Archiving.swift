//
//  Archiving.swift
//  PupKit
//
//  (c) 2016 @toddheasley
//

import Foundation

protocol Archiving {
    var manifest: [String] {
        get
    }
    
    var dictionary: [String: Any] {
        get
    }
    
    init(dictionary: [String: Any])
}

struct ArchivingKeys {
    static let name = "name"
    static let URI = "URI"
    static let URL = "URL"
    static let twitter = "twitter"
    static let pages = "pages"
    static let index = "index"
    static let body = "body"
}
