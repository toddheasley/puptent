//
//  HTMLTests.swift
//  PupKit
//
//  (c) 2015 @toddheasley
//

import XCTest

class HTMLTests: XCTestCase {
    func testGenerate() {
        let page = Page()
        page.URI = "page.html"
        
        let site = Site()
        site.URI = "site.html"
        site.pages.append(page)
        
        var count: Int = 0
        HTML.generate(site) { URI, data in
            XCTAssertTrue(["site.html", "page.html"].contains(URI))
            XCTAssertNotNil(data)
            count++
        }
        XCTAssertTrue(count == 2)
    }
}
