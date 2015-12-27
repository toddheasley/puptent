//
//  HTMLTests.swift
//  PupKit
//
//  (c) 2015 @toddheasley
//

import XCTest

class HTMLTests: XCTestCase {
    func testGenerate() {
        let page = Page()
        page.URI = "page.html"
        
        let site = Site()
        site.URI = "site.html"
        site.pages.append(page)
        
        var count: Int = 0
        HTML.generate(site) { URI, data in
            XCTAssertTrue(["site.html", "page.html"].contains(URI))
            XCTAssertNotNil(data)
            count++
        }
        XCTAssertTrue(count == 2)
    }
    
    func testString() {
        XCTAssertEqual(HTML(string: "/media/page.m4a"), "<audio src=\"/media/page.m4a\" preload=\"metadata\" controls>")
        XCTAssertEqual(HTML(string: "/media/page.MP3"), "<audio src=\"/media/page.MP3\" preload=\"metadata\" controls>")
        XCTAssertEqual(HTML(string: "/media/page.m4v"), "<video src=\"/media/page.m4v\" preload=\"metadata\" controls>")
        XCTAssertEqual(HTML(string: "/media/page.MOV"), "<video src=\"/media/page.MOV\" preload=\"metadata\" controls>")
        XCTAssertEqual(HTML(string: "/media/page.png"), "<a href=\"/media/page.png\"><img src=\"/media/page.png\"></a>")
        XCTAssertEqual(HTML(string: "/media/page.JPG"), "<a href=\"/media/page.JPG\"><img src=\"/media/page.JPG\"></a>")
        XCTAssertEqual(HTML(string: "http://example.com\n"), "<a href=\"http://example.com\">example.com</a><br>")
        XCTAssertEqual(HTML(string: "\nhttp://example.com"), "<br><a href=\"http://example.com\">example.com</a>")
        XCTAssertEqual(HTML(string: "\n/page.html"), "<br><a href=\"/page.html\">page.html</a>")
        XCTAssertEqual(HTML(string: "mail@example.com"), "<a href=\"mailto:mail@example.com\">mail@example.com</a>")
        XCTAssertEqual(HTML(string: "\nmail@example.com \n"), "<br><a href=\"mailto:mail@example.com\">mail@example.com</a> <br>")
        XCTAssertEqual(HTML(string: "@name"), "<a href=\"https://twitter.com/name\">@name</a>")
        XCTAssertEqual(HTML(string: " @name\n"), " <a href=\"https://twitter.com/name\">@name</a><br>")
        XCTAssertEqual(HTML(string: "#hashtag"), "<a href=\"https://twitter.com/search?q=%23hashtag&src=hash\">#hashtag</a>")
    }
}

class StringTests: XCTestCase {
    func testManifest() {
        XCTAssertEqual("Image: /media/page.jpg and audio: /media/page.m4a".manifest.count, 2)
        XCTAssertTrue("Image: /media/page.jpg and audio: /media/page.m4a".manifest.contains("media/page.jpg"))
        XCTAssertTrue("Image: /media/page.jpg and audio: /media/page.m4a".manifest.contains("media/page.m4a"))
    }
    
    func testURIFormat() {
        XCTAssertEqual("Page Name".URIFormat, "page-name\(Manager.URIExtension)")
        XCTAssertEqual("page-name.html".URIFormat, "page-name\(Manager.URIExtension)")
        XCTAssertEqual("page-name.txt".URIFormat, "page-nametxt\(Manager.URIExtension)")
    }
    
    func testTwitterFormat() {
        XCTAssertEqual("@name".twitterFormat(), "@name")
        XCTAssertEqual("@name".twitterFormat(false), "name")
        XCTAssertEqual("name".twitterFormat(), "@name")
    }
    
    func testTrim() {
        XCTAssertEqual("\n String with whitespace\n".trim(), "String with whitespace")
    }
}
