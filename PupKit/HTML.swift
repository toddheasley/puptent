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
    static let newLine: String = "\n"
    
    static func generate(site: Site, completion: (URI: String, data: NSData) -> Void) {
        for page in site.pages {
            var mainElements: [String] = page.body.componentsSeparatedByString("\(HTML.newLine)\(HTML.newLine)").map{
                p(HTML(string: $0))
            }
            mainElements.insert(h1("\(page.name)"), atIndex: 0)
            
            // Generate page HTML
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
                    p(HTML(string: site.twitter.isEmpty ? "" : "@\(site.twitter)"))
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
                p(HTML(string: site.twitter.isEmpty ? "" : "@\(site.twitter)"))
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
            ("(^|\\s)/([\\w\\-\\.!~#?&=+\\*'\"(),\\/]+).(m4a|mp3)", "$1<audio src=\"$2.$3\" preload=\"metadata\" controls>"), // Embed local audio
            ("(^|\\s)/([\\w\\-\\.!~#?&=+\\*'\"(),\\/]+).(m4v|mov|mp4)", "$1<video src=\"$2.$3\" preload=\"metadata\" controls>"), // Embed local video
            ("(^|\\s)/([\\w\\-\\.!~#?&=+\\*'\"(),\\/]+).(png|gif|jpg|jpeg)", "$1<a href=\"$2.$3\"><img src=\"$2.$3\"></a>"), // Embed local images
            ("(https?:\\/\\/)([\\w\\-\\.!~?&+\\*'\"(),\\/]+)", "<a href=\"$1$2\">$2</a>"), // Hyperlink absolute URLs
            ("(^|\\s)/([\\w\\-\\.!~#?&=+\\*'\"(),\\/]+)", "$1<a href=\"$2\">$2</a>"), // Hyperlink relative URIs
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

extension String {
    public var manifest: [String] {
        let expression = try! NSRegularExpression(pattern: "(^|\\s)/([\\w\\-\\.!~#?&=+\\*'\"(),\\/]+)", options: .CaseInsensitive)
        return expression.matchesInString(self, options: NSMatchingOptions(), range: NSMakeRange(0, characters.count)).map{
            ((self as NSString).substringWithRange($0.range).trim() as NSString).stringByReplacingOccurrencesOfString("/", withString: "", options: NSStringCompareOptions(), range: NSMakeRange(0, 1))
        }
    }
    
    public var URIFormat: String {
        var string = lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // Separate words with hyphens
        string = string.stringByReplacingOccurrencesOfString(" ", withString: "-")
        
        // Strip existing file extension
        string = string.stringByReplacingOccurrencesOfString("\(Manager.URIExtension)", withString: "")
        
        // Strip all non-alphanumeric characters
        string = string.stringByReplacingOccurrencesOfString("[^0-9a-z-_]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
        return string.isEmpty ? "" : "\(string)\(Manager.URIExtension)"
    }
    
    public func twitterFormat(format: Bool = true) -> String {
        let string = stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByReplacingOccurrencesOfString("@", withString: "")
        return format ? "@\(string)" : string
    }
    
    public func trim() -> String {
        return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}
