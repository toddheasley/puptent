//
//  SettingsViewTests.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import XCTest

class NSColorTests: XCTestCase {
    func testString() {
        XCTAssertNil(NSColor(string: "FFFFFF"))
        XCTAssertNil(NSColor(string: ""))
        XCTAssertNil(NSColor(string: "#FFFF"))
        XCTAssertEqual(NSColor(string: "#09D800")!.redComponent * 255.0, 9.0)
        XCTAssertEqual(NSColor(string: "#09D800")!.greenComponent * 255.0, 216.0)
        XCTAssertEqual(NSColor(string: "#09D800")!.blueComponent * 255.0, 0.0)
        XCTAssertEqual(NSColor(string: "#NNNNNN")!.string, "#000000")
        XCTAssertEqual(NSColor(string: "#09D800")!.string, "#09D800")
        XCTAssertEqual(NSColor(string: "#EDEDED")!.string, "#EDEDED")
    }
}
