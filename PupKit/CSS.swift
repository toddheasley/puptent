//
//  CSS.swift
//  PupKit
//
//  (c) 2016 @toddheasley
//

import Foundation

public enum FontFamily: String {
    case Serif = "serif"
    case Sans = "sans-serif"
    case Mono = "monospace"
    
    init?(string: String) {
        guard let range = string.rangeOfString("(serif|sans-serif|monospace)", options: .RegularExpressionSearch) else {
            return nil
        }
        self.init(rawValue: string.substringWithRange(range))
    }
}

public class CSS {
    public var font: FontFamily = .Serif
    public var backgroundColor: String = "#FFFFFF"
    public var textColor: String = "#000000"
    public var linkColor: (link: String, visited: String) = ("#0000E9", "#420078")
    
    private func value(target: String, property: String, selector: String? = nil) -> String? {
        var target = target.stringByReplacingOccurrencesOfString(String.newLine, withString: "")
        if let selector = selector where !selector.isEmpty {
            let matches = try! NSRegularExpression(pattern: "\(selector) \\{[^\\}]+\\}", options: .CaseInsensitive).matchesInString(target, options: NSMatchingOptions(), range: NSMakeRange(0, target.characters.count)).map{ result in
                return ((target as NSString).substringWithRange(result.range).trim() as NSString)
            }
            if (matches.isEmpty) {
                return nil
            }
            target = matches[0] as String
        }
        let expression = try! NSRegularExpression(pattern: "(\(property)): ([^;]+);", options: .CaseInsensitive)
        let matches = expression.matchesInString(target, options: NSMatchingOptions(), range: NSMakeRange(0, target.characters.count)).map{ result in
            return ((target as NSString).substringWithRange(result.range).trim() as NSString)
        }
        if (matches.isEmpty) {
            return nil
        }
        let match = matches[0] as String
        if (match.isEmpty) {
            return nil
        }
        return expression.stringByReplacingMatchesInString(match, options: [], range: NSMakeRange(0, match.characters.count), withTemplate: "$2")
    }
    
    private func block(selector: String, rules: [(property: String, value: String)]) -> String {
        return "\(selector) {\(join(rules))}"
    }
    
    private func media(selector: String, blocks: [String]) -> String {
        return "@media \(selector) {\(String.newLine)    \(join(blocks).replace("\(String.newLine)", "\(String.newLine)    "))\(String.newLine)}"
    }
    
    private func join(rules: [(property: String, value: String)]) -> String {
        return "\(String.newLine)" + rules.map{ rule in
            return "    \(rule.property): \(rule.value);"
        }.joinWithSeparator("\(String.newLine)") + "\(String.newLine)"
    }
    
    private func join(blocks: [String]) -> String {
        return blocks.joinWithSeparator("\(String.newLine)\(String.newLine)")
    }
    
    public func generate(completion: (data: NSData) -> Void) {
        completion(data: join([
            block("body", rules: [
                ("background", "\(backgroundColor)"),
                ("color", "\(textColor)"),
                ("font", "0.9em \(font.rawValue)"),
                ("letter-spacing", "0.03em"),
                ("margin", "auto"),
                ("max-width", "768px")
            ]),
            block("img, audio, video", rules: [
                ("width", "100%")
            ]),
            block("img", rules: [
                ("display", "block")
            ]),
            block("a", rules: [
                ("color", "\(linkColor.link)")
            ]),
            block("a:visited", rules: [
                ("color", "\(linkColor.visited)")
            ]),
            block("h1", rules: [
                ("font-size", "1em")
            ]),
            block("header h1", rules: [
                ("margin-bottom", "0")
            ]),
            block("article > h1", rules: [
                ("margin", "0.2em auto 4em auto")
            ]),
            block("article p:last-child, article > section:last-child", rules: [
                ("margin-bottom", "4em")
            ]),
            block("article > section:first-child", rules: [
                ("margin-top", "4em")
            ]),
            block("section", rules: [
                ("margin", "2em auto")
            ]),
            block("section p", rules: [
                ("margin", "0.2em auto")
            ]),
            media("(pointer: fine)", blocks: [
                block("header, article, footer", rules: [
                    ("margin", "auto 10px")
                ])
            ]),
            media("(pointer: coarse)", blocks: [
                block("header, article, footer", rules: [
                    ("margin", "auto 8px")
                ])
            ])
        ]).dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    public init(data: NSData = NSData()) {
        guard let string = String(data: data, encoding: NSUTF8StringEncoding) where !string.isEmpty else {
            return
        }
        if let value = value(string, property: "font"), font = FontFamily(string: value) {
            self.font = font
        }
        if let value = value(string, property: "background", selector: "body") {
            backgroundColor = value
        }
        if let value = value(string, property: "color", selector: "body") {
            textColor = value
        }
        if let value = value(string, property: "color", selector: "a") {
            linkColor.link = value
        }
        if let value = value(string, property: "color", selector: "a:visited") {
            linkColor.visited = value
        }
    }
}
