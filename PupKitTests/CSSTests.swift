import XCTest
@testable import PupKit

class CSSTests: XCTestCase {
    func testFont() {
        XCTAssertEqual(CSS.Font(string: "sans-serif"), .sans)
        XCTAssertEqual(CSS.Font(string: "12pt sans-serif"), .sans)
        XCTAssertEqual(CSS.Font(string: "9px monospace bold"), .mono)
        XCTAssertEqual(CSS.Font(string: "serif 1em"), .serif)
        XCTAssertNil(CSS.Font(string: ""))
    }
    
    func testGenerate() {
        var stylesheet: CSS = CSS()
        stylesheet.font = .mono
        stylesheet.backgroundColor = "#FF0000"
        stylesheet.textColor = "#0000FF"
        stylesheet.linkColor = ("#FFFF00", "#00FFFF")
        stylesheet.generate{ data in
            let stylesheet = CSS(data: data)
            XCTAssertEqual(stylesheet.font, .mono)
            XCTAssertEqual(stylesheet.backgroundColor, "#FF0000")
            XCTAssertEqual(stylesheet.textColor, "#0000FF")
            XCTAssertEqual(stylesheet.linkColor.link, "#FFFF00")
            XCTAssertEqual(stylesheet.linkColor.visited, "#00FFFF")
        }
    }
}
