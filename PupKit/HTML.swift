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
    static let viewport: String = "initial-scale=1.0"
    
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
        return "<header>\(join(elements, indent: true))</header>"
    }
    
    private static func footer(elements: [HTML]) -> HTML {
        return "<footer>\(join(elements, indent: true))</footer>"
    }
    
    private static func article(elements: [HTML]) -> HTML {
        return "<article>\(join(elements, indent: true))</article>"
    }
    
    private static func section(elements: [HTML]) -> HTML {
        return "<section>\(join(elements, indent: true))</section>"
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
    
    private static func join(elements: [HTML], indent: Bool = false) -> HTML {
        if (indent && !elements.isEmpty) {
            return "\(newLine)    " + elements.map{ element in
                return element.replace("\(newLine)", "\(newLine)    ")
                }.joinWithSeparator("\(newLine)    ") + newLine
        }
        return elements.joinWithSeparator(newLine)
    }
    
    static func generate(site: Site, completion: (URI: String, data: NSData) -> Void) {
        for page in site.pages {
            var articleElements: [String] = page.body.componentsSeparatedByString("\(HTML.newLine)\(HTML.newLine)").map{ string in
                return p(HTML(string: string))
            }
            articleElements.insert(h1("\(page.name)"), atIndex: 0)
            
            // Generate page HTML
            completion(URI: page.URI, data: join([
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
                article(articleElements),
                footer([
                    p(HTML(string: site.twitter.isEmpty ? "" : "@\(site.twitter)"))
                ])
            ]).dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        
        // Generate index HTML
        completion(URI: site.URI, data: join([
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
            article(site.indexedPages.map{ page in
                var sectionElements: [HTML] = [
                    p(a(page.URI, href: page.URI))
                ]
                if let image = page.body.image {
                    sectionElements.insert(p(img(image)), atIndex: 0)
                } else if let excerpt = page.body.excerpt {
                    sectionElements.insert(p(HTML(string: excerpt)), atIndex: 0)
                }
                return section(sectionElements)
            }),
            footer([
                p(HTML(string: site.twitter.isEmpty ? "" : "@\(site.twitter)"))
            ])
        ]).dataUsingEncoding(NSUTF8StringEncoding)!)
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
    public static let newLine: String = "\n"
    public static let separator: String = "-"
    
    var excerpt: String? {
        if let _ = image {
            return nil
        }
        return !split(String.newLine)[0].isEmpty ? split(String.newLine)[0] : nil
    }
    
    var image: String? {
        let expression = try! NSRegularExpression(pattern: "(^|\\s)/([\\w\\-\\.!~#?&=+\\*'\"(),\\/]+).(png|gif|jpg|jpeg)", options: .CaseInsensitive)
        let images = expression.matchesInString(self, options: NSMatchingOptions(), range: NSMakeRange(0, characters.count)).map{ result in
            return ((self as NSString).substringWithRange(result.range).trim() as NSString).stringByReplacingOccurrencesOfString("/", withString: "", options: NSStringCompareOptions(), range: NSMakeRange(0, 1))
        }
        if (!images.isEmpty && split(String.newLine)[0].containsString(images[0])) {
            return images[0]
        }
        return nil
    }
    
    public var manifest: [String] {
        let expression = try! NSRegularExpression(pattern: "(^|\\s)/([\\w\\-\\.!~#?&=+\\*'\"(),\\/]+)", options: .CaseInsensitive)
        return expression.matchesInString(self, options: NSMatchingOptions(), range: NSMakeRange(0, characters.count)).map{ result in
            return ((self as NSString).substringWithRange(result.range).trim() as NSString).stringByReplacingOccurrencesOfString("/", withString: "", options: NSStringCompareOptions(), range: NSMakeRange(0, 1))
        }
    }
    
    public var URIFormat: String {
        var string = lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // Separate words with hyphens
        string = string.stringByReplacingOccurrencesOfString(" ", withString: String.separator)
        
        // Strip existing file extension
        string = string.stringByReplacingOccurrencesOfString("\(Manager.URIExtension)", withString: "")
        
        // Strip all non-alphanumeric characters
        string = string.stringByReplacingOccurrencesOfString("[^0-9a-z-_]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
        return string.isEmpty ? "" : "\(string)\(Manager.URIExtension)"
    }
    
    public func twitterFormat(format: Bool = true) -> String {
        let string = stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByReplacingOccurrencesOfString("@", withString: "")
        return format && !string.isEmpty ? "@\(string)" : string
    }
    
    public func split(string: String) -> [String] {
        return componentsSeparatedByString(string)
    }
    
    public func replace(string: String, _ with: String) -> String {
        return stringByReplacingOccurrencesOfString(string, withString: with)
    }
    
    public func trim() -> String {
        return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}
