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

class PageView: NSTextView {
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
            attributedString.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, attributedString.length), options: .Reverse){ attachment, range, stop in
                if let attachment = attachment as? PageViewAttachment, attachmentPath = attachment.path {
                    let pathString = NSAttributedString(string: attachmentPath.stringByReplacingOccurrencesOfString(path, withString: "/"))
                    attributedString.replaceCharactersInRange(range, withAttributedString: pathString)
                }
            }
            attributedString.endEditing()
            return attributedString.string
        }
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        guard let _ = path, paths = sender.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as? [String] else {
            return false
        }
        sender.draggingPasteboard().clearContents()
        for path in paths {
            if let fileName = NSURL(fileURLWithPath: path).lastPathComponent {
                
                // Process dragged files; discard dragged directories
                var isDirectory = ObjCBool(false)
                if (NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory) && !isDirectory) {
                    let URL = NSURL(fileURLWithPath: "\(self.path!)\(Manager.mediaPath)/\(fileName)")
                    do {
                        
                        // Copy file into media directory
                        if (NSFileManager.defaultManager().fileExistsAtPath(URL.path!)) {
                            try NSFileManager.defaultManager().trashItemAtURL(URL, resultingItemURL: nil)
                        }
                        try NSFileManager.defaultManager().copyItemAtPath(path, toPath: URL.path!)
                    } catch {
                        Swift.print(error)
                        continue
                    }
                    
                    // Insert file as attachment
                    let attachmentString = NSMutableAttributedString(string: "")
                    if let attachment = PageViewAttachment(path: URL.path!) {
                        attachmentString.appendAttributedString(NSAttributedString(attachment: attachment))
                        attachmentString.appendAttributedString(NSAttributedString(string: "\n"))
                    }
                    let point: NSPoint = convertPoint(sender.draggingLocation(), fromView: nil)
                    textStorage?.replaceCharactersInRange(NSMakeRange(characterIndexForInsertionAtPoint(point), 0), withAttributedString: attachmentString)
                }
            }
        }
        textDidChange(nil)
        return true
    }
    
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textDidChange:", name: NSTextDidChangeNotification, object: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textDidChange:", name: NSTextDidChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: NSTextDidChangeNotification
    func textDidChange(notification: NSNotification?) {
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "pageViewDidChange", userInfo: nil, repeats: false)
    }
    
    func pageViewDidChange() {
        if let delegate = delegate as? PageViewDelegate {
            delegate.pageViewDidChange(self)
        }
    }
}
