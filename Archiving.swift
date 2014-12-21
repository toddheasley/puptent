//
//  Archiving.swift
//  PupTent
//
//  (c) 2014 @toddheasley
//

import Foundation

protocol Archiving {
    var manifest: Array<String> {
        get
    }
    
    var dictionary: NSDictionary {
        get
    }
    
    init(dictionary: NSDictionary)
}

struct ArchivingKeys {
    static let name = "name"
    static let URI = "URI"
    static let twitterName = "twitterName"
    static let domain = "domain"
    static let pages = "pages"
    static let index = "index"
    static let sections = "sections"
    static let type = "type"
    static let types = ["basic", "image", "audio", "video"]
    static let text = "text"
}
