//
//  HTML.swift
//  PupKit
//
//  (c) 2015 @toddheasley
//

import Foundation

public typealias HTML = String

enum HTMLMetaName: String {
    case Generator = "generator"
    case Viewport = "viewport"
    case BookmarkTitle = "apple-mobile-web-app-title"
}

enum HTMLLinkRel: String {
    case Stylesheet = "stylesheet"
    case BookmarkIcon = "apple-touch-icon"
}

extension HTML {
    public static let bookmarkIconURI: String = "apple-touch-icon.png"
    public static let stylesheetURI: String = "default.css"
    static let viewport: String = "initial-scale=1.0, user-scalable=no"
    private static let newLine: String = "\n"
    
    static func generate(site: Site, completion: (URI: String, data: NSData) -> Void) {
        for page in site.pages {
            
            // Generate page HTML
            var mainElements: [HTML] = [
                h1("\(page.name)")
            ]
            mainElements.appendContentsOf(page.sections.map{
                switch $0.type {
                case .Basic:
                    return p(HTML(string: $0.text))
                case .Image:
                    return figure(a(img($0.URI), href: $0.URI))
                case .Audio:
                    return figure(audio($0.URI))
                case .Video:
                    return figure(video($0.URI))
                }
            })
            completion(URI: page.URI, data: joinElements([
                doctype(),
                title("\(page.name) - \(site.name)"),
                meta(.Generator, content: "\(NSBundle.mainBundle().executableURL!.lastPathComponent!)"),
                meta(.Viewport, content: viewport),
                meta(.BookmarkTitle, content: "\(site.name)"),
                link(.BookmarkIcon, href: bookmarkIconURI),
                link(.Stylesheet, href: stylesheetURI),
                header([
                    h1(a("\(site.name)", href: site.URI))
                ]),
                main(mainElements),
                menu(site.indexedPages.map{
                    return p($0.URI == page.URI ? span($0.name) : a("\($0.name)", href: $0.URI))
                }),
                footer([
                    p(HTML(string: site.twitterName.isEmpty ? "" : "@\(site.twitterName)"))
                ])
            ]).dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        
        // Generate index HTML
        completion(URI: site.URI, data: joinElements([
            doctype(),
            title("\(site.name)"),
            meta(.Generator, content: "\(NSBundle.mainBundle().executableURL!.lastPathComponent!)"),
            meta(.Viewport, content: viewport),
            meta(.BookmarkTitle, content: "\(site.name)"),
            link(.BookmarkIcon, href: bookmarkIconURI),
            link(.Stylesheet, href: stylesheetURI),
            header([
                h1("\(site.name)")
            ]),
            menu(site.indexedPages.map{
                return p(a("\($0.name)", href: $0.URI))
            }),
            footer([
                p(HTML(string: site.twitterName.isEmpty ? "" : "@\(site.twitterName)"))
            ])
        ]).dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    private static func doctype() -> HTML {
        return "<!DOCTYPE html>"
    }
    
    private static func meta(name: HTMLMetaName, content: String) -> HTML {
        return "<meta name=\"\(name.rawValue)\" content=\"\(content)\">"
    }
    
    private static func link(rel: HTMLLinkRel, href: String) -> HTML {
        return "<link rel=\"\(rel.rawValue)\" href=\"\(href)\">"
    }
    
    private static func title(string: String) -> HTML {
        return "<title>\(string)</title>"
    }
    
    private static func header(elements: [HTML]) -> HTML {
        return "<header>\(joinElements(elements, indent: true))</header>"
    }
    
    private static func footer(elements: [HTML]) -> HTML {
        return "<footer>\(joinElements(elements, indent: true))</footer>"
    }
    
    private static func main(elements: [HTML]) -> HTML {
        return "<main>\(joinElements(elements, indent: true))</main>"
    }
    
    private static func menu(elements: [HTML]) -> HTML {
        return "<menu>\(joinElements(elements, indent: true))</menu>"
    }
    
    private static func h1(content: HTML) -> HTML {
        return "<h1>\(content)</h1>"
    }
    
    private static func p(content: HTML) -> HTML {
        return "<p>\(content)</p>"
    }
    
    private static func figure(content: HTML) -> HTML {
        return "<figure>\(content)</figure>"
    }
    
    private static func audio(src: String) -> HTML {
        return "<audio src=\"\(src)\" preload=\"metadata\" controls></audio>"
    }
    
    private static func video(src: String) -> HTML {
        return "<video src=\"\(src)\" preload=\"metadata\" controls></video>"
    }
    
    private static func img(src: String) -> HTML {
        return "<img src=\"\(src)\">"
    }
    
    private static func a(content: HTML, href: String) -> HTML {
        return "<a href=\"\(href)\">\(content)</a>"
    }
    
    private static func span(content: HTML) -> HTML {
        return "<span>\(content)</span>"
    }
    
    private static func joinElements(elements: [HTML], indent: Bool = false) -> HTML {
        if (indent && !elements.isEmpty) {
            return "\(newLine)    " + elements.joinWithSeparator("\(newLine)    ") + newLine
        }
        return elements.joinWithSeparator(newLine)
    }
    
    init(string: String) {
        let patterns: [(String, String)] = [
            ("(https?:\\/\\/)([\\w\\-\\.!~?&+\\*'\"(),\\/]+)", "<a href=\"$1$2\">$2</a>"), // Hyperlink absolute URLs
            ("(^|\\\n|\\s)/([\\w\\-\\.!~#?&=+\\*'\"(),\\/]+)", "$1<a href=\"/$2\">$2</a>"), // Hyperlink relative URIs
            ("(^|\\s)([A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4})", "$1<a href=\"mailto:$2\">$2</a>"), // Hyperlink email addresses
            ("(^|\\s)@([a-z0-9_]+)", "$1<a href=\"https://twitter.com/$2\">@$2</a>"), // Hyperlink Twitter names
            ("(^|\\s)#([a-z0-9_]+)", "$1<a href=\"https://twitter.com/search?q=%23$2&src=hash\">#$2</a>") // Hyperlink Twitter hashtags
        ]
        
        var HTML = string
        for pattern in patterns {
            HTML = (try! NSRegularExpression(pattern: pattern.0, options: NSRegularExpressionOptions.CaseInsensitive)).stringByReplacingMatchesInString(HTML as String, options: [], range: NSMakeRange(0, HTML.characters.count), withTemplate: pattern.1)
        }
        HTML = HTML.stringByReplacingOccurrencesOfString("\n", withString: "<br>")
        self.init(HTML)
    }
}
