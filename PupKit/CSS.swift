import Foundation

public struct CSS {
    public enum Font: String {
        case serif, sans = "sans-serif", mono = "monospace"
        
        init?(string: String) {
            guard let range: Range = string.range(of: "(serif|sans-serif|monospace)", options: .regularExpression) else {
                return nil
            }
            self.init(rawValue: String(string[range]))
        }
    }
    
    public var backgroundColor: String = "#FFFFFF"
    public var textColor: String = "#000000"
    public var linkColor: (link: String, visited: String) = ("#0000E9", "#420078")
    public var font: Font = .serif
    
    public func generate(completion: (Data) -> Void) {
        completion(join(blocks: [
            block(selector: "body", rules: [
                ("background", "\(backgroundColor)"),
                ("color", "\(textColor)"),
                ("font", "0.9em \(font.rawValue)"),
                ("letter-spacing", "0.03em"),
                ("margin", "auto"),
                ("max-width", "768px")
            ]),
            block(selector: "img, audio, video", rules: [
                ("width", "100%")
            ]),
            block(selector: "img", rules: [
                ("display", "block")
            ]),
            block(selector: "a", rules: [
                ("color", "\(linkColor.link)")
            ]),
            block(selector: "a:visited", rules: [
                ("color", "\(linkColor.visited)")
            ]),
            block(selector: "h1", rules: [
                ("font-size", "1em")
            ]),
            block(selector: "header h1", rules: [
                ("margin-bottom", "0")
            ]),
            block(selector: "article > h1", rules: [
                ("margin", "0.2em auto 4em auto")
            ]),
            block(selector: "article p:last-child, article > section:last-child", rules: [
                ("margin-bottom", "4em")
            ]),
            block(selector: "article > section:first-child", rules: [
                ("margin-top", "4em")
            ]),
            block(selector: "section", rules: [
                ("margin", "2em auto")
            ]),
            block(selector: "section p", rules: [
                ("margin", "0.2em auto")
            ]),
            media(selector: "(pointer: fine)", blocks: [
                block(selector: "header, article, footer", rules: [
                    ("margin", "auto 10px")
                ])
            ]),
            media(selector: "(pointer: coarse)", blocks: [
                block(selector: "header, article, footer", rules: [
                    ("margin", "auto 8px")
                ])
            ])
        ]).data(using: .utf8)!)
    }
    
    public init(data: Data = Data()) {
        guard let target: String = String(data: data, encoding: .utf8), !target.isEmpty else {
            return
        }
        backgroundColor = value(target: target, property: "background", selector: "body") ?? backgroundColor
        textColor = value(target: target, property: "color", selector: "body") ?? textColor
        linkColor.link = value(target: target, property: "color", selector: "a") ?? linkColor.link
        linkColor.visited = value(target: target, property: "color", selector: "a:visited") ?? linkColor.visited
        font = Font(string: value(target: target, property: "font") ?? "") ?? font
    }
    
    private func value(target: String, property: String, selector: String? = nil) -> String? {
        var target: String = target.replacingOccurrences(of: String.newLine, with: "")
        if let selector: String = selector, !selector.isEmpty {
            let matches: [String] = try! NSRegularExpression(pattern: "\(selector) \\{[^\\}]+\\}", options: .caseInsensitive).matches(in: target, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, target.count)).map{ result in
                return (target as NSString).substring(with: result.range).trim() as String
            }
            guard let match: String = matches.first else {
                return nil
            }
            target = match
        }
        let expression: NSRegularExpression = try! NSRegularExpression(pattern: "(\(property)): ([^;]+);", options: .caseInsensitive)
        let matches: [String] = expression.matches(in: target, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, target.count)).map{ result in
            return (target as NSString).substring(with: result.range).trim() as String
        }
        guard let match: String = matches.first, !match.isEmpty else {
            return nil
        }
        return expression.stringByReplacingMatches(in: match, options: [], range: NSMakeRange(0, match.count), withTemplate: "$2")
    }
    
    private func block(selector: String, rules: [(property: String, value: String)]) -> String {
        return "\(selector) {\(join(rules: rules))}"
    }
    
    private func media(selector: String, blocks: [String]) -> String {
        return "@media \(selector) {\(String.newLine)    \(join(blocks: blocks).replace(string: "\(String.newLine)", "\(String.newLine)    "))\(String.newLine)}"
    }
    
    private func join(rules: [(property: String, value: String)]) -> String {
        return "\(String.newLine)" + rules.map{ rule in
            return "    \(rule.property): \(rule.value);"
        }.joined(separator: "\(String.newLine)") + "\(String.newLine)"
    }
    
    private func join(blocks: [String]) -> String {
        return blocks.joined(separator: "\(String.newLine)\(String.newLine)")
    }
}
