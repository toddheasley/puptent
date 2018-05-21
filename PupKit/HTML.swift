import Foundation

public typealias HTML = String

extension HTML {
    enum MetaName: String {
        case generator = "generator"
        case viewport = "viewport"
        case bookmarkTitle = "apple-mobile-web-app-title"
        case twitterCard = "twitter:card"
        case twitterTitle = "twitter:title"
        case twitterDescription = "twitter:description"
        case twitterImage = "twitter:image"
        case twitterSite = "twitter:site"
    }

    enum LinkRel: String {
        case stylesheet = "stylesheet"
        case bookmarkIcon = "apple-touch-icon"
    }
    
    public static let bookmarkIcon: String = "apple-touch-icon.png"
    public static let stylesheet: String = "default.css"
    private static let viewport: String = "initial-scale=1.0"
    
    private static func doctype() -> HTML {
        return "<!DOCTYPE html>"
    }
    
    private static func meta(name: MetaName, content: String) -> HTML {
        return "<meta name=\"\(name.rawValue)\" content=\"\(content)\">"
    }
    
    private static func link(rel: LinkRel, href: String) -> HTML {
        return "<link rel=\"\(rel.rawValue)\" href=\"\(href)\">"
    }
    
    private static func title(string: String) -> HTML {
        return "<title>\(string)</title>"
    }
    
    private static func header(elements: [HTML]) -> HTML {
        return "<header>\(join(elements: elements, indent: true))</header>"
    }
    
    private static func footer(elements: [HTML]) -> HTML {
        return "<footer>\(join(elements: elements, indent: true))</footer>"
    }
    
    private static func article(elements: [HTML]) -> HTML {
        return "<article>\(join(elements: elements, indent: true))</article>"
    }
    
    private static func section(elements: [HTML]) -> HTML {
        return "<section>\(join(elements: elements, indent: true))</section>"
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
        if indent && !elements.isEmpty {
            return "\(newLine)    " + elements.map{ element in
                return element.replace(string: "\(newLine)", "\(newLine)    ")
                }.joined(separator: "\(newLine)    ") + newLine
        }
        return elements.joined(separator: newLine)
    }
    
    static func generate(site: Site, completion: (String, Data) -> Void) {
        for page in site.pages {
            
            // Generate page HTML
            var articleElements: [String] = page.body.components(separatedBy: "\(HTML.newLine)\(HTML.newLine)").map{ string in
                return p(content: HTML(string: string))
            }
            articleElements.insert(h1(content: "\(page.name)"), at: 0)
            var pageElements: [String] = [
                doctype(),
                title(string: "\(page.name) - \(site.name)"),
                meta(name: .generator, content: "\(Bundle.main.executableURL!.lastPathComponent)"),
                meta(name: .viewport, content: viewport),
                meta(name: .bookmarkTitle, content: "\(site.name)"),
                link(rel: .bookmarkIcon, href: bookmarkIcon),
                link(rel: .stylesheet, href: stylesheet),
                header(elements: [
                    h1(content: a(content: "\(site.name)", href: site.uri))
                ]),
                article(elements: articleElements),
                footer(elements: [
                    p(content: HTML(string: (site.twitter?.isEmpty ?? true) ? "" : "\(site.twitter!.twitterFormat())"))
                ])
            ]
            if let excerpt: String = page.body.excerpt, let twitter: String = site.twitter, !twitter.isEmpty {
                var twitterElements: [String] = [
                    meta(name: .twitterSite, content: "\(twitter.twitterFormat())"),
                    meta(name: .twitterTitle, content: "\(page.name)"),
                    meta(name: .twitterDescription, content: "\(excerpt)")
                ]
                if let image: String = page.body.image, let url: URL = site.url, let imageURL: URL = URL(string: image, relativeTo: url) {
                    twitterElements.insert(meta(name: .twitterCard, content: "summary_large_image"), at: 0)
                    twitterElements.append(meta(name: .twitterImage, content: "\(imageURL.absoluteString)"))
                } else {
                    twitterElements.insert(meta(name: .twitterCard, content: "summary"), at: 0)
                }
                pageElements.insert(contentsOf: twitterElements, at: 4)
            }
            completion(page.uri, join(elements: pageElements).data(using: .utf8)!)
        }
        
        // Generate index HTML
        let indexElements: [String] = [
            doctype(),
            title(string: "\(site.name)"),
            meta(name: .generator, content: "\(Bundle.main.executableURL!.lastPathComponent)"),
            meta(name: .viewport, content: viewport),
            meta(name: .bookmarkTitle, content: "\(site.name)"),
            link(rel: .bookmarkIcon, href: bookmarkIcon),
            link(rel: .stylesheet, href: stylesheet),
            header(elements: [
                h1(content: "\(site.name)")
            ]),
            article(elements: site.indexedPages.map{ page in
                var sectionElements: [HTML] = [
                    p(content: a(content: page.uri, href: page.uri))
                ]
                if let image = page.body.image, page.body.hasPrefix("/\(image)") {
                    sectionElements.insert(p(content: a(content: img(src: image), href: page.uri)), at: 0)
                } else if let excerpt = page.body.excerpt, page.body.hasPrefix("\(excerpt)") {
                    sectionElements.insert(p(content: HTML(string: excerpt)), at: 0)
                }
                return section(elements: sectionElements)
            }),
            footer(elements: [
                p(content: HTML(string: (site.twitter?.isEmpty ?? true) ? "" : "\(site.twitter!.twitterFormat())"))
            ])
        ]
        completion(site.uri, join(elements: indexElements).data(using: String.Encoding.utf8)!)
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
            HTML = (try! NSRegularExpression(pattern: pattern.0, options: NSRegularExpression.Options.caseInsensitive)).stringByReplacingMatches(in: HTML as String, options: [], range: NSMakeRange(0, HTML.count), withTemplate: pattern.1)
        }
        HTML = HTML.replacingOccurrences(of: "\n", with: "<br>")
        self = HTML
    }
}

extension String {
    public static let newLine: String = "\n"
    public static let separator: String = "-"
    
    public var excerpt: String? {
        for string in split(string: String.newLine) {
            if !string.isEmpty && string.images.isEmpty {
                return string
            }
        }
        return nil
    }
    
    public var image: String? {
        return images.isEmpty ? nil : images[0]
    }
    
    public var images: [String] {
        return find(expression: try! NSRegularExpression(pattern: "(^|\\s)/([\\w\\-\\.!~#?&=+\\*'\"(),\\/]+).(png|gif|jpg|jpeg)", options: .caseInsensitive))
    }
    
    public var manifest: [String] {
        return find(expression: try! NSRegularExpression(pattern: "(^|\\s)/([\\w\\-\\.!~#?&=+\\*'\"(),\\/]+)", options: .caseInsensitive))
    }
    
    public var uriFormat: String {
        var string: String = lowercased().trimmingCharacters(in: CharacterSet.whitespaces)
        
        // Separate words with hyphens
        string = string.replace(string: " ", String.separator)
        
        // Strip existing file extension
        string = string.replace(string: ".html", "")
        
        // Strip all non-alphanumeric characters
        string = string.replacingOccurrences(of: "[^0-9a-z-_]", with: "", options: .regularExpression, range: nil)
        return string.isEmpty ? "" : "\(string).html"
    }
    
    public var urlFormat: String {
        return lowercased().trim()
    }
    
    public func twitterFormat(format: Bool = true) -> String {
        let string: String = trimmingCharacters(in: CharacterSet.whitespaces).replacingOccurrences(of: "@", with: "")
        return format && !string.isEmpty ? "@\(string)" : string
    }
    
    public func split(string: String) -> [String] {
        return components(separatedBy: string)
    }
    
    public func replace(string: String, _ with: String) -> String {
        return replacingOccurrences(of: string, with: with)
    }
    
    public func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    private func find(expression: NSRegularExpression) -> [String] {
        return expression.matches(in: self, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, count)).map{ result in
            return ((self as NSString).substring(with: result.range).trim() as NSString).replacingOccurrences(of: "/", with: "", options: NSString.CompareOptions(), range: NSMakeRange(0, 1))
        }
    }
}
