//
//  MainViewControllerTests.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import XCTest

class NSUserDefaultsTests: XCTestCase {
    func testPath() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("path")
        XCTAssertNotNil(NSUserDefaults.standardUserDefaults().path)
        XCTAssertTrue(NSUserDefaults.standardUserDefaults().path.isEmpty)
        NSUserDefaults.standardUserDefaults().path = "/Users/Documents"
        XCTAssertEqual(NSUserDefaults.standardUserDefaults().path, "/Users/Documents")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("path")
    }
}
