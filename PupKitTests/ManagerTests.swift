//
//  ManagerTests.swift
//  PupKit
//
//  (c) 2015 @toddheasley
//

import XCTest

class ManagerTests: XCTestCase {
    let path: String = "\(NSTemporaryDirectory())PupKitTests/"
    
    override func setUp() {
        super.setUp()
        do {
            if (NSFileManager.defaultManager().fileExistsAtPath(self.path)) {
                try NSFileManager.defaultManager().removeItemAtPath(self.path)
            }
            try NSFileManager.defaultManager().createDirectoryAtPath(self.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testPitch() {
        do {
            try Manager.pitch(self.path)
            XCTAssertTrue(Manager.exists(self.path))
            _ = try Manager(path: self.path)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testBuild() {
        do {
            try Manager.pitch(self.path)
            var manager = try Manager(path: self.path)
            manager.site.name = "Site"
            try manager.build()
            manager = try Manager(path: self.path)
            XCTAssertEqual(manager.site.name, "Site")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testClean() {
        do {
            try Manager.pitch(self.path)
            NSData().writeToFile("\(self.path)README.md", atomically: true)
            NSData().writeToFile("\(self.path)CNAME", atomically: true)
            NSData().writeToFile("\(self.path)\(Manager.mediaPath)/extra.jpg", atomically: true)
            NSData().writeToFile("\(self.path)extra.txt", atomically: true)
            try Manager(path: self.path).clean()
            XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath("\(self.path)README.md"))
            XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath("\(self.path)CNAME"))
            XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath("\(self.path)\(Manager.mediaPath)/extra.jpg"))
            XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath("\(self.path)extra.txt"))
        } catch {
            XCTFail("\(error)")
        }
    }
    
    override func tearDown() {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(self.path)
        } catch {
            XCTAssert(false, "\(error)")
        }
        super.tearDown()
    }
}
