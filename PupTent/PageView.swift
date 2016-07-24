//
//  PageView.swift
//  PupTent
//
//  (c) 2016 @toddheasley
//

import Cocoa
import PupKit

@objc protocol PageViewDelegate: NSTextViewDelegate {
    func pageViewDidChange(_ view: PageView)
}

class PageView: NSTextView, NSTextStorageDelegate {
    private var timer: Timer?
    var path: String?
    
    override var string: String? {
        set{
            scrollRangeToVisible(NSMakeRange(0, 0)) // Reset scroll position
            super.string = ""
            guard let newValue = newValue, let path = path, let textStorage = textStorage else {
                return
            }
            
            // Expand file paths in string
            let string = (try! RegularExpression(pattern: "(^|\\s)/([\\w\\-\\.!~#?&=+\\*'\"(),\\/]+)", options: .caseInsensitive)).stringByReplacingMatches(in: newValue, options: [], range: NSMakeRange(0, newValue.characters.count), withTemplate: "$1\(path)$2")
            
            // Replace file paths with attachments
            let attributedString = NSMutableAttributedString(string: string)
            let matches = (try! RegularExpression(pattern: "\(path)([\\w\\-\\.!~#?&=+\\*'\"(),\\/]+)", options: .caseInsensitive)).matches(in: string, options: RegularExpression.MatchingOptions(), range: NSMakeRange(0, string.characters.count))
            for match in matches.reversed() {
                var attachmentString = AttributedString(string: "")
                if let attachment = PageViewAttachment(path: (string as NSString).substring(with: match.range)) {
                    attachmentString = AttributedString(attachment: attachment)
                }
                attributedString.replaceCharacters(in: match.range, with: attachmentString)
            }
            textStorage.append(attributedString)
        }
        get{
            guard let path = path, let textStorage = textStorage else {
                return nil
            }
            
            // Replace attachments with file paths
            let attributedString = NSMutableAttributedString(attributedString: textStorage)
            attributedString.beginEditing()
            attributedString.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, attributedString.length), options: .reverse){ attachment, range, _ in
                if let attachment = attachment as? PageViewAttachment, let attachmentPath = attachment.path {
                    let pathString = AttributedString(string: attachmentPath.replacingOccurrences(of: path, with: "/"))
                    attributedString.replaceCharacters(in: range, with: pathString)
                }
            }
            attributedString.endEditing()
            return attributedString.string
        }
    }
    
    override func didChangeText() {
        super.didChangeText()
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(PageView.pageViewDidChange), userInfo: nil, repeats: false)
    }
    
    func pageViewDidChange() {
        if let delegate = delegate as? PageViewDelegate {
            delegate.pageViewDidChange(self)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        textStorage?.delegate = self
        textContainerInset = NSMakeSize(11.0, 13.0)
    }
    
    // MARK: NSTextStorageDelegate
    func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        textStorage.enumerateAttributes(in: editedRange, options: AttributedString.EnumerationOptions()){ attributes, range, _ in
            for (name, value) in attributes {
                if let _ = value as? PageViewAttachment {
                    continue // Attachmnet already processed; skip
                }
                guard let path = self.path, let attachment = value as? NSTextAttachment, let fileWrapper = attachment.fileWrapper, let filename = fileWrapper.preferredFilename, let data = fileWrapper.regularFileContents, name == NSAttachmentAttributeName && fileWrapper.isRegularFile else {
                    
                    // Attribute isn't a file attachment; strip attribute
                    textStorage.removeAttribute(name, range: range)
                    continue
                }
                
                // Copy attached file to media directory
                let URL = Foundation.URL(fileURLWithPath: "\(path)\(Manager.mediaPath)/\(filename.replacingOccurrences(of: " ", with: String.separator))")
                do {
                    if (FileManager.default.fileExists(atPath: URL.path!)) {
                        try FileManager.default.trashItem(at: URL, resultingItemURL: nil)
                    }
                    let _ = try? data.write(to: URL, options: [.atomicWrite])
                } catch {
                    
                    // File copy failed; strip attribute
                    textStorage.removeAttribute(name, range: range)
                    continue
                }
                
                // Replace attachment
                let attachmentString = NSMutableAttributedString(string: "")
                if let attachment = PageViewAttachment(path: URL.path!) {
                    attachmentString.append(AttributedString(attachment: attachment))
                }
                textStorage.replaceCharacters(in: range, with: attachmentString)
            }
        }
    }
}
