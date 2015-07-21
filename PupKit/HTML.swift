//
//  HTML.swift
//  PupKit
//
//  (c) 2015 @toddheasley
//

import Foundation

public class HTML {
    public static let bookmarkIconURI: String = "apple-touch-icon.png"
    public static let stylesheetURI: String = "default.css"
    
    public class func generate(site: Site, completionHandler: (URI: String, data: NSData) -> Void) {
        var pages: [Page] = site.pages
        
        // Add site index page
        let index = Page()
        index.URI = site.URI
        pages.append(index)
        
        for page in pages {
            var HTML: [String] = []
            HTML.extend([
                "<!DOCTYPE html>"
            ])
            if (!page.name.isEmpty) {
                HTML.append("<title>\(page.name) - \(site.name)</a></title")
            } else {
                HTML.append("<title>\(site.name)</title>")
            }
            HTML.extend([
                "<meta name=\"generator\" content=\"\(NSBundle.mainBundle().executablePath!.lastPathComponent)\">",
                "<meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=no\">",
                "<meta name=\"apple-mobile-web-app-title\" content=\"\(site.name)\">",
                "<link rel=\"apple-touch-icon\" href=\"\(self.bookmarkIconURI)\">",
                "<link rel=\"stylesheet\" href=\"\(self.stylesheetURI)\">"
            ])
            HTML.extend([
                "<header>"
            ])
            if (page.URI != site.URI) {
               HTML.append("    <h1><a href=\"\(site.URI)\">\(site.name)</a></h1>")
            } else {
               HTML.append("    <h1>\(site.name)</h1>")
            }
            HTML.extend([
                "</header>"
            ])
            if (page.URI != site.URI) {
                HTML.extend([
                    "<main>",
                    "    <h1>\(page.name)</h1>"
                ])
                for section in page.sections {
                    switch section.type {
                    case .Image:
                        HTML.append("    <figure><a href=\"\(section.URI)\"><img src=\"\(section.URI)\"></a></figure>")
                    case .Audio:
                        HTML.append("    <figure><audio src=\"\(section.URI)\" preload=\"metadata\" controls></audio></figure>")
                    case .Video:
                        HTML.append("    <figure><video src=\"\(section.URI)\" preload=\"metadata\" controls></video></figure>")
                    case .Basic:
                        HTML.append("    <p>\(section.text)</p>")
                    }
                }
                HTML.extend([
                    "</main>"
                ])
            }
            HTML.extend([
                "<menu>",
                "    <hr>",
                "    <ul>"
            ])
            for indexedPage: Page in site.indexedPages {
                var menuItem: String = "<span>\(indexedPage.name)</span>"
                if (indexedPage.URI != page.URI) {
                    menuItem = "<a href=\"\(indexedPage.URI)\">\(indexedPage.name)</a>"
                }
                HTML.extend([
                    "        <li>\(menuItem)</li>"
                ])
            }
            HTML.extend([
                "    </ul>",
                "</menu>"
            ])
            HTML.extend([
                "<footer>"
            ])
            if (!site.twitterName.isEmpty) {
                HTML.append("    <p><a href=\"https://twitter.com/\(site.twitterName)\">\(site.twitterName)</a></p>")
            }
            HTML.extend([
                "</footer>"
            ])
            
            // Return HTML data for page URI
            completionHandler(URI: page.URI, data: "\n".join(HTML).dataUsingEncoding(NSUTF8StringEncoding)!)
        }
    }
}

extension String {
    func toHTML(detectLinks: Bool) -> String {
        let patterns = [
            ("(https?:\\/\\/)([\\w\\-\\.!~?&+\\*'\"(),\\/]+)", "<a href=\"$1$2\">$2</a>"), // Hyperlink absolute URLs
            ("(^|\\\n|\\s)/([\\w\\-\\.!~#?&=+\\*'\"(),\\/]+)", "$1<a href=\"/$2\">$2</a>"), // Hyperlink relative URIs
            ("(^|\\s)([A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4})", "$1<a href=\"mailto:$2\">$2</a>"), // Hyperlink email addresses
            ("(^|\\s)@([a-z0-9_]+)", "$1<a href=\"https://twitter.com/$2\">@$2</a>"), // Hyperlink Twitter names
            ("(^|\\s)#([a-z0-9_]+)", "$1<a href=\"https://twitter.com/search?q=%23$2&src=hash\">#$2</a>") // Hyperlink Twitter hashtags
        ]
        var HTML: NSString = self
        if (detectLinks) {
            for pattern: (String, String) in patterns {
                HTML = (try! NSRegularExpression(pattern: pattern.0, options: NSRegularExpressionOptions.CaseInsensitive)).stringByReplacingMatchesInString(HTML as String, options: [], range: NSMakeRange(0, HTML.length), withTemplate: pattern.1)
            }
        }
        
        // Convert line breaks
        HTML = HTML.stringByReplacingOccurrencesOfString("\n", withString: "<br>")
        return HTML as String
    }
}
