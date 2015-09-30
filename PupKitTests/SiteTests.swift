//
//  SiteTests.swift
//  PupKit
//
//  (c) 2015 @toddheasley
//

import XCTest

class SiteTests: XCTestCase {
    var site: Site!
    let dictionary: [String: AnyObject] = [
        ArchivingKeys.name: "Site",
        ArchivingKeys.URI: "index.html",
        ArchivingKeys.twitterName: "twitter",
        ArchivingKeys.pages: [
            [
                ArchivingKeys.index: false,
                ArchivingKeys.name: "Page 1",
                ArchivingKeys.URI: "page1.html",
                ArchivingKeys.sections: []
            ], [
                ArchivingKeys.index: true,
                ArchivingKeys.name: "Page 2",
                ArchivingKeys.URI: "page2.html",
                ArchivingKeys.sections: []
            ]
        ]
    ]
    
    func testDictionary() {
        XCTAssertEqual(site.dictionary[ArchivingKeys.name] as? String, dictionary[ArchivingKeys.name] as? String)
        XCTAssertEqual(site.dictionary[ArchivingKeys.URI] as? String, dictionary[ArchivingKeys.URI] as? String)
        XCTAssertEqual(site.dictionary[ArchivingKeys.twitterName] as? String, dictionary[ArchivingKeys.twitterName] as? String)
        XCTAssertEqual((site.dictionary[ArchivingKeys.pages] as! [AnyObject]).count, 2)
    }
    
    func testManifest() {
        XCTAssertEqual(site.manifest, ["page1.html", "page2.html", "index.html"])
    }
    
    override func setUp() {
        super.setUp()
        site = Site(dictionary: dictionary)
        XCTAssertEqual(site.name, "Site")
        XCTAssertEqual(site.URI, "index.html")
        XCTAssertEqual(site.twitterName, "twitter")
        XCTAssertEqual(site.pages.count, 2)
        XCTAssertEqual(site.pages[0].name, "Page 1")
        XCTAssertEqual(site.indexedPages.count, 1)
        XCTAssertEqual(site.indexedPages[0].name, "Page 2")
    }
}
