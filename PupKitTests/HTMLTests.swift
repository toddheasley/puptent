import XCTest
@testable import PupKit

class HTMLTests: XCTestCase {
    func testGenerate() {
        var page = Page()
        page.uri = "page.html"
        var site = Site()
        site.uri = "site.html"
        site.pages.append(page)
        var count: Int = 0
        HTML.generate(site: site) { uri, data in
            XCTAssertTrue(["site.html", "page.html"].contains(uri))
            XCTAssertNotNil(data)
            count += 1
        }
        XCTAssertTrue(count == 2)
    }
    
    func testString() {
        XCTAssertEqual(HTML(string: "/media/page.m4a"), "<audio src=\"media/page.m4a\" preload=\"metadata\" controls>")
        XCTAssertEqual(HTML(string: "/media/page.MP3"), "<audio src=\"media/page.MP3\" preload=\"metadata\" controls>")
        XCTAssertEqual(HTML(string: "/media/page.m4v"), "<video src=\"media/page.m4v\" preload=\"metadata\" controls>")
        XCTAssertEqual(HTML(string: "/media/page.MOV"), "<video src=\"media/page.MOV\" preload=\"metadata\" controls>")
        XCTAssertEqual(HTML(string: "/media/page.png"), "<a href=\"media/page.png\"><img src=\"media/page.png\"></a>")
        XCTAssertEqual(HTML(string: "/media/page.JPG"), "<a href=\"media/page.JPG\"><img src=\"media/page.JPG\"></a>")
        XCTAssertEqual(HTML(string: "http://example.com\n"), "<a href=\"http://example.com\">example.com</a><br>")
        XCTAssertEqual(HTML(string: "\nhttp://example.com"), "<br><a href=\"http://example.com\">example.com</a>")
        XCTAssertEqual(HTML(string: "\n/page.html"), "<br><a href=\"page.html\">page.html</a>")
        XCTAssertEqual(HTML(string: "mail@example.com"), "<a href=\"mailto:mail@example.com\">mail@example.com</a>")
        XCTAssertEqual(HTML(string: "\nmail@example.com \n"), "<br><a href=\"mailto:mail@example.com\">mail@example.com</a> <br>")
        XCTAssertEqual(HTML(string: "@name"), "<a href=\"https://twitter.com/name\">@name</a>")
        XCTAssertEqual(HTML(string: " @name\n"), " <a href=\"https://twitter.com/name\">@name</a><br>")
        XCTAssertEqual(HTML(string: "#hashtag"), "<a href=\"https://twitter.com/search?q=%23hashtag&src=hash\">#hashtag</a>")
    }
}

class StringTests: XCTestCase {
    func testExcerpt() {
        XCTAssertNil("".excerpt)
        XCTAssertNil("/media/page.gif and\n/media/page.jpg".excerpt)
        XCTAssertEqual("String\n and whitespace".excerpt, "String")
        XCTAssertEqual("String".excerpt, "String")
        XCTAssertEqual("/media/page.gif and\n/media/page.jpg\nString and whitespace".excerpt, "String and whitespace")
    }
    
    func testImage() {
        XCTAssertNil("String and whitespace".image)
        XCTAssertEqual("String and /media/page.gif".image, "media/page.gif")
        XCTAssertEqual("/media/page.gif and string".image, "media/page.gif")
    }
    
    func testImages() {
        XCTAssertTrue("String and whitespace".images.isEmpty)
        XCTAssertEqual("/media/page.jpg and string\n/media/page.gif".images, ["media/page.jpg", "media/page.gif"])
        XCTAssertEqual("String and /media/page.gif".images, ["media/page.gif"])
    }
    
    func testManifest() {
        XCTAssertEqual("Image: /media/page.jpg and audio: /media/page.m4a".manifest.count, 2)
        XCTAssertTrue("Image: /media/page.jpg and audio: /media/page.m4a".manifest.contains("media/page.jpg"))
        XCTAssertTrue("Image: /media/page.jpg and audio: /media/page.m4a".manifest.contains("media/page.m4a"))
    }
    
    func testURIFormat() {
        XCTAssertEqual("Page Name".uriFormat, "page-name.html")
        XCTAssertEqual("page-name.html".uriFormat, "page-name.html")
        XCTAssertEqual("page-name.txt".uriFormat, "page-nametxt.html")
    }
    
    func testURLFormat() {
        XCTAssertEqual("".urlFormat, "")
        XCTAssertEqual(" Username.GitHub.IO".urlFormat, "username.github.io")
    }
    
    func testTwitterFormat() {
        XCTAssertEqual("@name".twitterFormat(), "@name")
        XCTAssertEqual("@name".twitterFormat(format: false), "name")
        XCTAssertEqual("name".twitterFormat(), "@name")
    }
    
    func testSplit() {
        XCTAssertEqual("String with whitespace".split(string: " ").count, 3)
        XCTAssertEqual("String with whitespace".split(string: " "), ["String", "with", "whitespace"])
        XCTAssertEqual("String".split(string: " ").count, 1)
        XCTAssertEqual("String".split(string: " "), ["String"])
        XCTAssertEqual("".split(string: " ").count, 1)
        XCTAssertEqual("".split(string: " "), [""])
    }
    
    func testReplace() {
        XCTAssertEqual("\n String with\nwhitespace".replace(string: "\n", " "), "  String with whitespace")
        XCTAssertEqual("String with whitespace".replace(string: "\n", "\t"), "String with whitespace")
    }
    
    func testTrim() {
        XCTAssertEqual("\n String with whitespace\n".trim(), "String with whitespace")
    }
}
