//
//  PageTests.swift
//  PupKit
//
//  (c) 2015 @toddheasley
//

import XCTest

class PageTests: XCTestCase {
    var page: Page?
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
    
    override func setUp() {
        super.setUp()
        self.page = Page(dictionary: self.dictionary)
        XCTAssertTrue(self.page!.index)
        XCTAssertEqual(self.page!.name, "Page")
        XCTAssertEqual(self.page!.URI, "page.html")
        XCTAssertEqual(self.page!.sections[0].text, "Section")
    }
    
    func testDictionary() {
        XCTAssertEqual(self.page!.dictionary[ArchivingKeys.index] as! Bool, self.dictionary[ArchivingKeys.index] as! Bool)
        XCTAssertEqual(self.page!.dictionary[ArchivingKeys.name] as! String, self.dictionary[ArchivingKeys.name] as! String)
        XCTAssertEqual(self.page!.dictionary[ArchivingKeys.URI] as! String, self.dictionary[ArchivingKeys.URI] as! String)
        XCTAssertEqual((self.page!.dictionary[ArchivingKeys.sections] as! [AnyObject]).count, 1)
    }
    
    func testManifest() {
        XCTAssertEqual(self.page!.manifest, ["section.jpg", "page.html"])
    }
}

class PageSectionTests: XCTestCase {
    var pageSection: PageSection?
    let dictionary: [String: AnyObject] = [
        ArchivingKeys.type: "image",
        ArchivingKeys.text: "Section",
        ArchivingKeys.URI: "section.jpg"
    ]
    
    override func setUp() {
        super.setUp()
        self.pageSection = PageSection(dictionary: self.dictionary)
        XCTAssertEqual(self.pageSection!.type.rawValue, "image")
        XCTAssertEqual(self.pageSection!.text, "Section")
        XCTAssertEqual(self.pageSection!.URI, "section.jpg")
    }
    
    func testDictionary() {
        XCTAssertEqual(self.pageSection!.dictionary[ArchivingKeys.type] as! String, self.dictionary[ArchivingKeys.type] as! String)
        XCTAssertEqual(self.pageSection!.dictionary[ArchivingKeys.text] as! String, self.dictionary[ArchivingKeys.text] as! String)
        XCTAssertEqual(self.pageSection!.dictionary[ArchivingKeys.URI] as! String, self.dictionary[ArchivingKeys.URI] as! String)
    }
    
    func testManifest() {
        XCTAssertEqual(self.pageSection!.manifest, ["section.jpg"])
    }
}
