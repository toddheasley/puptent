//
//  CSS.swift
//  PupKit
//
//  (c) 2016 @toddheasley
//

import Foundation

public enum FontFamily: String {
    case serif = "serif"
    case sans = "sans-serif"
    case mono = "monospace"
    
    init?(string: String) {
        guard let range = string.range(of: "(serif|sans-serif|monospace)", options: .regularExpression) else {
            return nil
        }
        self.init(rawValue: string.substring(with: range))
    }
}

public class CSS {
    public var font: FontFamily = .serif
    public var backgroundColor: String = "#FFFFFF"
    public var textColor: String = "#000000"
    public var linkColor: (link: String, visited: String) = ("#0000E9", "#420078")
    
    private func value(target: String, property: String, selector: String? = nil) -> String? {
        var target = target.replacingOccurrences(of: String.newLine, with: "")
        if let selector = selector, !selector.isEmpty {
            let matches = try! RegularExpression(pattern: "\(selector) \\{[^\\}]+\\}", options: .caseInsensitive).matches(in: target, options: RegularExpression.MatchingOptions(), range: NSMakeRange(0, target.characters.count)).map{ result in
                return ((target as NSString).substring(with: result.range).trim() as NSString)
            }
            if (matches.isEmpty) {
                return nil
            }
            target = matches[0] as String
        }
        let expression = try! RegularExpression(pattern: "(\(property)): ([^;]+);", options: .caseInsensitive)
        let matches = expression.matches(in: target, options: RegularExpression.MatchingOptions(), range: NSMakeRange(0, target.characters.count)).map{ result in
            return ((target as NSString).substring(with: result.range).trim() as NSString)
        }
        if (matches.isEmpty) {
            return nil
        }
        let match = matches[0] as String
        if (match.isEmpty) {
            return nil
        }
        return expression.stringByReplacingMatches(in: match, options: [], range: NSMakeRange(0, match.characters.count), withTemplate: "$2")
    }
    
    private func block(selector: String, rules: [(property: String, value: String)]) -> String {
        return "\(selector) {\(join(rules: rules)))}"
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
    
    public func generate(completion: (data: Data) -> Void) {
        completion(data: join(blocks: [
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
        ]).data(using: String.Encoding.utf8)!)
    }
    
    public init(data: Data = Data()) {
        guard let string = String(data: data, encoding: String.Encoding.utf8), !string.isEmpty else {
            return
        }
        if let value = value(target: string, property: "font"), let font = FontFamily(string: value) {
            self.font = font
        }
        if let value = value(target: string, property: "background", selector: "body") {
            backgroundColor = value
        }
        if let value = value(target: string, property: "color", selector: "body") {
            textColor = value
        }
        if let value = value(target: string, property: "color", selector: "a") {
            linkColor.link = value
        }
        if let value = value(target: string, property: "color", selector: "a:visited") {
            linkColor.visited = value
        }
    }
}
