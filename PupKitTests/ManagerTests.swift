//
//  ManagerTests.swift
//  PupKit
//
//  (c) 2015 @toddheasley
//

import XCTest

class ManagerTests: XCTestCase {
    let path: String = "\(NSTemporaryDirectory())PupKitTests/"
    
    func testPitch() {
        do {
            try Manager.pitch(path)
            XCTAssertTrue(Manager.exists(path))
            _ = try Manager(path: path)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testBuild() {
        do {
            try Manager.pitch(path)
            var manager = try Manager(path: path)
            manager.site.name = "Site"
            try manager.build()
            manager = try Manager(path: path)
            XCTAssertEqual(manager.site.name, "Site")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testClean() {
        do {
            try Manager.pitch(path)
            NSData().writeToFile("\(path)README.md", atomically: true)
            NSData().writeToFile("\(path)CNAME", atomically: true)
            NSData().writeToFile("\(path)\(Manager.mediaPath)/extra.jpg", atomically: true)
            NSData().writeToFile("\(path)extra.txt", atomically: true)
            try Manager(path: path).clean()
            XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath("\(path)README.md"))
            XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath("\(path)CNAME"))
            XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath("\(path)\(Manager.mediaPath)/extra.jpg"))
            XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath("\(path)extra.txt"))
        } catch {
            XCTFail("\(error)")
        }
    }
    
    override func setUp() {
        super.setUp()
        do {
            if (NSFileManager.defaultManager().fileExistsAtPath(path)) {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            }
            try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    override func tearDown() {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
        } catch {
            XCTAssert(false, "\(error)")
        }
        super.tearDown()
    }
}
