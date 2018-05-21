import XCTest
@testable import PupKit

class SiteTests: XCTestCase {
    
    // MARK: Resource
    func testManifest() {
        var page: Page = Page()
        page.uri = "page.html"
        var site: Site = Site()
        site.pages.append(page)
        XCTAssertEqual(site.manifest.count, 2)
        XCTAssertTrue(site.manifest.contains("index.html"))
        XCTAssertTrue(site.manifest.contains("page.html"))
    }
}
