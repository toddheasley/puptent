import XCTest
@testable import PupKit

class PageTests: XCTestCase {
    
    // MARK: Resource
    func testManifest() {
        var page: Page = Page()
        page.name = "Page"
        page.body = "Image: /media/page.jpg and audio: /media/page.m4a"
        page.uri = "page.html"
        XCTAssertEqual(page.manifest.count, 3)
        XCTAssertTrue(page.manifest.contains("media/page.jpg"))
        XCTAssertTrue(page.manifest.contains("media/page.m4a"))
        XCTAssertTrue(page.manifest.contains("page.html"))
    }
}
