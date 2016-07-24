//
//  CSSTests.swift
//  PupKit
//
//  (c) 2016 @toddheasley
//

import XCTest

class FontFamilyTests: XCTestCase {
    func testString() {
        XCTAssertEqual(FontFamily(string: "sans-serif"), FontFamily.sans)
        XCTAssertEqual(FontFamily(string: "12pt sans-serif"), FontFamily.sans)
        XCTAssertEqual(FontFamily(string: "9px monospace bold"), FontFamily.mono)
        XCTAssertEqual(FontFamily(string: "serif 1em"), FontFamily.serif)
        XCTAssertNil(FontFamily(string: ""))
    }
}

class CSSTests: XCTestCase {
    func testGenerate() {
        let stylesheet = CSS()
        stylesheet.font = .mono
        stylesheet.backgroundColor = "#FF0000"
        stylesheet.textColor = "#0000FF"
        stylesheet.linkColor = ("#FFFF00", "#00FFFF")
        stylesheet.generate{ data in
            let stylesheet = CSS(data: data)
            XCTAssertEqual(stylesheet.font, FontFamily.mono)
            XCTAssertEqual(stylesheet.backgroundColor, "#FF0000")
            XCTAssertEqual(stylesheet.textColor, "#0000FF")
            XCTAssertEqual(stylesheet.linkColor.link, "#FFFF00")
            XCTAssertEqual(stylesheet.linkColor.visited, "#00FFFF")
        }
    }
}
