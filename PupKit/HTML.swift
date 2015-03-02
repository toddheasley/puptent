//
//  HTML.swift
//  PupKit
//
//  (c) 2015 @toddheasley
//

import Foundation

public protocol HTMLDelegate {
    func handleHTML(HTML: String, URI: String) -> NSError?
}

public class HTML {
    public class func generate(site: Site, bookmarkIconURI: String, stylesheetURI: String, delegate: HTMLDelegate) -> NSError? {
        for page in site.pages {
            if let error = delegate.handleHTML("".join([
                HTML.head(site, page: page, bookmarkIconURI: bookmarkIconURI, stylesheetURI: stylesheetURI),
                HTML.header(site, page: page),
                HTML.main(site, page: page),
                HTML.menu(site, page: page),
                HTML.footer(site)
            ]), URI: page.URI) as NSError? {
                return error
            }
        }
        return delegate.handleHTML("".join([
            HTML.head(site, page: nil, bookmarkIconURI: bookmarkIconURI, stylesheetURI: stylesheetURI),
            HTML.header(site, page: nil),
            HTML.menu(site, page: nil),
            HTML.footer(site)
        ]), URI: site.URI)
    }
    
    private class func head(site: Site, page: Page?, bookmarkIconURI: String, stylesheetURI: String) -> String {
        var title = site.name
        if (page != nil) {
            title = "\(page!.name) - \(title)"
        }
        
        var HTML = [
            "<!DOCTYPE html>\n",
            "<title>\(title)</title>\n",
            "<meta name=\"generator\" content=\"\(NSBundle.mainBundle().executablePath!.lastPathComponent)\">\n",
            "<meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=no\">\n",
            "<meta name=\"apple-mobile-web-app-title\" content=\"\(site.name)\">\n",
            "<link rel=\"apple-touch-icon\" href=\"\(bookmarkIconURI)\">\n",
            "<link rel=\"stylesheet\" href=\"\(stylesheetURI)\">\n"
        ]
        if (page != nil && !site.twitterName.isEmpty) {
            
            // Twitter card support
            for section in page!.sections {
                if (section.type == PageSectionType.Image) {
                    HTML.extend([
                        "<meta name=\"twitter:creator\" content=\"\(site.twitterName)\">\n",
                        "<meta name=\"twitter:card\" content=\"photo\">\n",
                        "<meta name=\"twitter:title\" content=\"\">\n",
                        "<meta name=\"twitter:image:src\" content=\"/\(section.URI)\">\n"
                        ])
                    break
                }
            }
        }
        return "".join(HTML)
    }
    
    private class func header(site: Site, page: Page?) -> String {
        var h1 = site.name
        if (page != nil) {
            h1 = "<a href=\"\(site.URI)\">\(site.name)</a>"
        }
        return "".join([
            "<header>\n",
            "    <h1>\(h1)</h1>\n",
            "</header>\n"
        ])
    }
    
    private class func footer(site: Site) -> String {
        var p = ""
        if (!site.twitterName.isEmpty) {
            p = "    <p><a href=\"https://twitter.com/\(site.twitterName)\">@\(site.twitterName)</a></p>\n"
        }
        return "".join([
            "<footer>\n",
            p,
            "</footer>"
        ])
    }
    
    private class func main(site: Site, page: Page) -> String {
        var HTML = [
            "<main>\n",
            "    <h1>\(page.name)</h1>\n"
        ]
        for section in page.sections {
            switch (section.type) {
            case PageSectionType.Image:
                HTML.append("    <figure><a href=\"\(section.URI)\"><img src=\"\(section.URI)\"></a></figure>\n")
            case PageSectionType.Audio:
                HTML.append("    <figure><audio src=\"\(section.URI)\" preload=\"metadata\" controls></audio></figure>\n")
            case PageSectionType.Video:
                HTML.append("    <figure><video src=\"\(section.URI)\" preload=\"metadata\" controls></video></figure>\n")
            case PageSectionType.Basic:
                HTML.append("    <p>\(section.text.toHTML(true))</p>\n")
            }
        }
        HTML.extend([
            "</main>\n"
        ])
        return "".join(HTML)
    }
    
    private class func menu(site: Site, page: Page?) -> String {
        var HTML = [
            "<menu>\n",
            "    <hr>\n",
            "    <ul>\n"
        ]
        for indexedPage in site.indexedPages {
            if (page != nil && indexedPage.URI == page!.URI) {
                HTML.append("        <li><span>\(indexedPage.name)</span></li>\n")
            } else {
                HTML.append("        <li><a href=\"\(indexedPage.URI)\">\(indexedPage.name)</a></li>\n")
            }
        }
        HTML.extend([
            "    </ul>\n",
            "</menu>\n"
        ])
        return "".join(HTML)
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
                HTML = NSRegularExpression(pattern: pattern.0, options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!.stringByReplacingMatchesInString(HTML as String, options: nil, range: NSMakeRange(0, HTML.length), withTemplate: pattern.1)
            }
        }
        
        // Convert line breaks
        HTML = HTML.stringByReplacingOccurrencesOfString("\n", withString: "<br>")
        
        return HTML as String
    }
}
