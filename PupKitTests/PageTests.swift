//
//  PageTests.swift
//  PupKit
//
//  (c) 2015 @toddheasley
//

import XCTest

class PageTests: XCTestCase {
    var page: Page!
    let dictionary: [String: AnyObject] = [
        ArchivingKeys.index: true,
        ArchivingKeys.name: "Page",
        ArchivingKeys.URI: "page.html",
        ArchivingKeys.sections: [
            [
                ArchivingKeys.type: "image",
                ArchivingKeys.text: "Section",
                ArchivingKeys.URI: "section.jpg"
            ]
        ]
    ]
    
    func testDictionary() {
        XCTAssertEqual(page.dictionary[ArchivingKeys.index] as? Bool, dictionary[ArchivingKeys.index] as? Bool)
        XCTAssertEqual(page.dictionary[ArchivingKeys.name] as? String, dictionary[ArchivingKeys.name] as? String)
        XCTAssertEqual(page.dictionary[ArchivingKeys.URI] as? String, dictionary[ArchivingKeys.URI] as? String)
        XCTAssertEqual((page.dictionary[ArchivingKeys.sections] as! [AnyObject]).count, 1)
    }
    
    func testManifest() {
        XCTAssertEqual(page.manifest, ["section.jpg", "page.html"])
    }
    
    override func setUp() {
        super.setUp()
        page = Page(dictionary: dictionary)
        XCTAssertTrue(page.index)
        XCTAssertEqual(page.name, "Page")
        XCTAssertEqual(page.URI, "page.html")
        XCTAssertEqual(page.sections[0].text, "Section")
    }
}

class PageSectionTests: XCTestCase {
    var pageSection: PageSection!
    let dictionary: [String: AnyObject] = [
        ArchivingKeys.type: "image",
        ArchivingKeys.text: "Section",
        ArchivingKeys.URI: "section.jpg"
    ]
    
    func testDictionary() {
        XCTAssertEqual(pageSection.dictionary[ArchivingKeys.type] as? String, dictionary[ArchivingKeys.type] as? String)
        XCTAssertEqual(pageSection.dictionary[ArchivingKeys.text] as? String, dictionary[ArchivingKeys.text] as? String)
        XCTAssertEqual(pageSection.dictionary[ArchivingKeys.URI] as? String, dictionary[ArchivingKeys.URI] as? String)
    }
    
    func testManifest() {
        XCTAssertEqual(pageSection.manifest, ["section.jpg"])
    }
    
    override func setUp() {
        super.setUp()
        pageSection = PageSection(dictionary: dictionary)
        XCTAssertEqual(pageSection.type.rawValue, "image")
        XCTAssertEqual(pageSection.text, "Section")
        XCTAssertEqual(pageSection.URI, "section.jpg")
    }
}
