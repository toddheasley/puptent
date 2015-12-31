//
//  PageView.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa
import PupKit

@objc protocol PageViewDelegate: NSTextViewDelegate {
    func pageViewDidChange(view: PageView)
}

class PageView: NSTextView, NSTextStorageDelegate {
    private var timer: NSTimer?
    var path: String?
    
    override var string: String? {
        set{
            scrollRangeToVisible(NSMakeRange(0, 0)) // Reset scroll position
            super.string = ""
            guard let newValue = newValue, path = path, textStorage = textStorage else {
                return
            }
            
            // Expand file paths in string
            let string = (try! NSRegularExpression(pattern: "(^|\\s)/([\\w\\-\\.!~#?&=+\\*'\"(),\\/]+)", options: .CaseInsensitive)).stringByReplacingMatchesInString(newValue, options: [], range: NSMakeRange(0, newValue.characters.count), withTemplate: "$1\(path)$2")
            
            // Replace file paths with attachments
            let attributedString = NSMutableAttributedString(string: string)
            let matches = (try! NSRegularExpression(pattern: "\(path)([\\w\\-\\.!~#?&=+\\*'\"(),\\/]+)", options: .CaseInsensitive)).matchesInString(string, options: NSMatchingOptions(), range: NSMakeRange(0, string.characters.count))
            for match in matches.reverse() {
                var attachmentString = NSAttributedString(string: "")
                if let attachment = PageViewAttachment(path: (string as NSString).substringWithRange(match.range)) {
                    attachmentString = NSAttributedString(attachment: attachment)
                }
                attributedString.replaceCharactersInRange(match.range, withAttributedString: attachmentString)
            }
            textStorage.appendAttributedString(attributedString)
        }
        get{
            guard let path = path, textStorage = textStorage else {
                return nil
            }
            
            // Replace attachments with file paths
            let attributedString = NSMutableAttributedString(attributedString: textStorage)
            attributedString.beginEditing()
            attributedString.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, attributedString.length), options: .Reverse){ attachment, range, _ in
                if let attachment = attachment as? PageViewAttachment, attachmentPath = attachment.path {
                    let pathString = NSAttributedString(string: attachmentPath.stringByReplacingOccurrencesOfString(path, withString: "/"))
                    attributedString.replaceCharactersInRange(range, withAttributedString: pathString)
                }
            }
            attributedString.endEditing()
            return attributedString.string
        }
    }
    
    override func didChangeText() {
        super.didChangeText()
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "pageViewDidChange", userInfo: nil, repeats: false)
    }
    
    func pageViewDidChange() {
        if let delegate = delegate as? PageViewDelegate {
            delegate.pageViewDidChange(self)
        }
    }
    
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        textStorage?.delegate = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        textStorage?.delegate = self
    }
    
    // MARK: NSTextStorageDelegate
    func textStorage(textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        textStorage.enumerateAttributesInRange(editedRange, options: NSAttributedStringEnumerationOptions()){ attributes, range, _ in
            for (name, value) in attributes {
                if let _ = value as? PageViewAttachment {
                    continue // Attachmnet already processed; skip
                }
                guard let path = self.path, attachment = value as? NSTextAttachment, fileWrapper = attachment.fileWrapper, filename = fileWrapper.preferredFilename, data = fileWrapper.regularFileContents where name == NSAttachmentAttributeName && fileWrapper.regularFile else {
                    
                    // Attribute isn't a file attachment; strip attribute
                    textStorage.removeAttribute(name, range: range)
                    continue
                }
                
                // Copy attached file to media directory
                let URL = NSURL(fileURLWithPath: "\(path)\(Manager.mediaPath)/\(filename.stringByReplacingOccurrencesOfString(" ", withString: String.separator))")
                do {
                    if (NSFileManager.defaultManager().fileExistsAtPath(URL.path!)) {
                        try NSFileManager.defaultManager().trashItemAtURL(URL, resultingItemURL: nil)
                    }
                    data.writeToURL(URL, atomically: true)
                } catch {
                    Swift.print(error)
                }
                
                // Replace attachment
                let attachmentString = NSMutableAttributedString(string: "")
                if let attachment = PageViewAttachment(path: URL.path!) {
                    attachmentString.appendAttributedString(NSAttributedString(attachment: attachment))
                }
                textStorage.replaceCharactersInRange(range, withAttributedString: attachmentString)
            }
        }
    }
}
