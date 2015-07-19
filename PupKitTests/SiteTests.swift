//
//  SiteTests.swift
//  PupKit
//
//  (c) 2015 @toddheasley
//

import XCTest

class SiteTests: XCTestCase {
    var site: Site?
    let dictionary: [String: AnyObject] = [
        ArchivingKeys.name: "Site",
        ArchivingKeys.URI: "index.html",
        ArchivingKeys.baseURL: "http://example.com",
        ArchivingKeys.twitterName: "twitter",
        ArchivingKeys.pages: [
            [
                ArchivingKeys.index: false,
                ArchivingKeys.name: "Page1",
                ArchivingKeys.URI: "page1.html",
                ArchivingKeys.sections: []
            ], [
                ArchivingKeys.index: true,
                ArchivingKeys.name: "Page2",
                ArchivingKeys.URI: "page2.html",
                ArchivingKeys.sections: []
            ]
        ]
    ]
    
    override func setUp() {
        super.setUp()
        self.site = Site(dictionary: self.dictionary)
        XCTAssertEqual(self.site!.name, "Site")
        XCTAssertEqual(self.site!.URI, "index.html")
        XCTAssertEqual(self.site!.baseURL, "http://example.com")
        XCTAssertEqual(self.site!.twitterName, "twitter")
        XCTAssertEqual(self.site!.pages.count, 2)
        XCTAssertEqual(self.site!.pages[0].name, "Page1")
        XCTAssertEqual(self.site!.indexedPages.count, 1)
        XCTAssertEqual(self.site!.indexedPages[0].name, "Page2")
    }
    
    func testDictionary() {
        XCTAssertEqual(self.site!.dictionary[ArchivingKeys.name] as! String, self.dictionary[ArchivingKeys.name] as! String)
        XCTAssertEqual(self.site!.dictionary[ArchivingKeys.URI] as! String, self.dictionary[ArchivingKeys.URI] as! String)
        XCTAssertEqual(self.site!.dictionary[ArchivingKeys.baseURL] as! String, self.dictionary[ArchivingKeys.baseURL] as! String)
        XCTAssertEqual(self.site!.dictionary[ArchivingKeys.twitterName] as! String, self.dictionary[ArchivingKeys.twitterName] as! String)
        XCTAssertEqual((self.site!.dictionary[ArchivingKeys.pages] as! [AnyObject]).count, 2)
    }
    
    func testManifest() {
        XCTAssertEqual(self.site!.manifest, ["page1.html", "page2.html", "index.html"])
    }
}
