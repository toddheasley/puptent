import XCTest
@testable import PupKit

class ManagerTests: XCTestCase {
    let path: String = "\(NSTemporaryDirectory())PupKitTests/"
    
    func testPitch() {
        do {
            try Manager.pitch(path: path)
            XCTAssertTrue(Manager.exists(path: path))
            _ = try Manager(path: path)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testBuild() {
        do {
            try Manager.pitch(path: path)
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
            try Manager.pitch(path: path)
            NSData().write(toFile: "\(path)README.md", atomically: true)
            NSData().write(toFile: "\(path)CNAME", atomically: true)
            NSData().write(toFile: "\(path)\(Manager.media)/extra.jpg", atomically: true)
            NSData().write(toFile: "\(path)extra.txt", atomically: true)
            try Manager(path: path).clean()
            XCTAssertTrue(FileManager.default.fileExists(atPath: "\(path)README.md"))
            XCTAssertTrue(FileManager.default.fileExists(atPath: "\(path)CNAME"))
            XCTAssertFalse(FileManager.default.fileExists(atPath: "\(path)\(Manager.media)/extra.jpg"))
            XCTAssertFalse(FileManager.default.fileExists(atPath: "\(path)extra.txt"))
        } catch {
            XCTFail("\(error)")
        }
    }
    
    override func setUp() {
        super.setUp()
        do {
            if FileManager.default.fileExists(atPath: path) {
                try FileManager.default.removeItem(atPath: path)
            }
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    override func tearDown() {
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            XCTAssert(false, "\(error)")
        }
        super.tearDown()
    }
}
