//
//  MainViewControllerTests.swift
//  PupTent
//
//  (c) 2016 @toddheasley
//

import XCTest

class NSUserDefaultsTests: XCTestCase {
    func testPath() {
        UserDefaults.standard.removeObject(forKey: "path")
        XCTAssertNotNil(UserDefaults.standard.path)
        XCTAssertTrue(UserDefaults.standard.path.isEmpty)
        UserDefaults.standard.path = "/Users/Documents"
        XCTAssertEqual(UserDefaults.standard.path, "/Users/Documents")
        UserDefaults.standard.removeObject(forKey: "path")
    }
}
