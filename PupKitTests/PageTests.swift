//
//  PageTests.swift
//  PupKit
//
//  (c) 2016 @toddheasley
//

import XCTest

class PageTests: XCTestCase {
    var page: Page!
    let dictionary: [String: AnyObject] = [
        ArchivingKeys.index: true,
        ArchivingKeys.name: "Page",
        ArchivingKeys.URI: "page.html",
        ArchivingKeys.body: "Image: /media/page.jpg and audio: /media/page.m4a"
    ]
    
    func testDictionary() {
        XCTAssertEqual(page.dictionary[ArchivingKeys.index] as? Bool, dictionary[ArchivingKeys.index] as? Bool)
        XCTAssertEqual(page.dictionary[ArchivingKeys.name] as? String, dictionary[ArchivingKeys.name] as? String)
        XCTAssertEqual(page.dictionary[ArchivingKeys.URI] as? String, dictionary[ArchivingKeys.URI] as? String)
        XCTAssertEqual((page.dictionary[ArchivingKeys.body] as! String), "Image: /media/page.jpg and audio: /media/page.m4a")
    }
    
    func testManifest() {
        XCTAssertEqual(page.manifest.count, 3)
        XCTAssertTrue(page.manifest.contains("media/page.jpg"))
        XCTAssertTrue(page.manifest.contains("media/page.m4a"))
        XCTAssertTrue(page.manifest.contains("page.html"))
    }
    
    override func setUp() {
        super.setUp()
        page = Page(dictionary: dictionary)
        XCTAssertTrue(page.index)
        XCTAssertEqual(page.name, "Page")
        XCTAssertEqual(page.URI, "page.html")
        XCTAssertEqual(page.body, "Image: /media/page.jpg and audio: /media/page.m4a")
    }
}
