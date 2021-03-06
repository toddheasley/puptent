import Cocoa
import PupKit

@objc protocol PageViewDelegate: NSTextViewDelegate {
    func pageViewDidChange(_ view: PageView)
}

class PageView: NSTextView, NSTextStorageDelegate {
    private var timer: Timer?
    var path: String?
    
    override var string: String {
        set{
            scrollRangeToVisible(NSMakeRange(0, 0)) // Reset scroll position
            super.string = ""
            guard let path: String = path, let textStorage: NSTextStorage = textStorage else {
                return
            }
            
            // Expand file paths in string
            let string: String = (try! NSRegularExpression(pattern: "(^|\\s)/([\\w\\-\\.!~#?&=+\\*'\"(),\\/]+)", options: .caseInsensitive)).stringByReplacingMatches(in: newValue, options: [], range: NSMakeRange(0, newValue.count), withTemplate: "$1\(path)$2")
            
            // Replace file paths with attachments
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
            let matches: [NSTextCheckingResult] = (try! NSRegularExpression(pattern: "\(path)([\\w\\-\\.!~#?&=+\\*'\"(),\\/]+)", options: .caseInsensitive)).matches(in: string, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, string.count))
            for match in matches.reversed() {
                var attachmentString: NSAttributedString = NSAttributedString(string: "")
                if let attachment: PageViewAttachment = PageViewAttachment(path: (string as NSString).substring(with: match.range)) {
                    attachmentString = NSAttributedString(attachment: attachment)
                }
                attributedString.replaceCharacters(in: match.range, with: attachmentString)
            }
            textStorage.append(attributedString)
        }
        get{
            guard let path: String = path, let textStorage: NSTextStorage = textStorage else {
                return ""
            }
            
            // Replace attachments with file paths
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(attributedString: textStorage)
            attributedString.beginEditing()
            attributedString.enumerateAttribute(NSAttributedStringKey.attachment, in: NSMakeRange(0, attributedString.length), options: .reverse){ attachment, range, _ in
                if let attachment: PageViewAttachment = attachment as? PageViewAttachment, let attachmentPath: String = attachment.path {
                    let pathString: NSAttributedString = NSAttributedString(string: attachmentPath.replacingOccurrences(of: path, with: "/"))
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
    
    @objc func pageViewDidChange() {
        (delegate as? PageViewDelegate)?.pageViewDidChange(self)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        textContainerInset = NSMakeSize(11.0, 13.0)
        textStorage?.delegate = self
    }
    
    // MARK: NSTextStorageDelegate
    func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        textStorage.enumerateAttributes(in: editedRange, options: NSAttributedString.EnumerationOptions()){ attributes, range, _ in
            for (name, value) in attributes {
                if let _ = value as? PageViewAttachment {
                    continue // Attachmnet already processed; skip
                }
                guard let path: String = self.path, let attachment: NSTextAttachment = value as? NSTextAttachment, let fileWrapper: FileWrapper = attachment.fileWrapper, let filename: String = fileWrapper.preferredFilename, let data: Data = fileWrapper.regularFileContents, name == NSAttributedStringKey.attachment && fileWrapper.isRegularFile else {
                    
                    // Attribute isn't a file attachment; strip attribute
                    textStorage.removeAttribute(name, range: range)
                    continue
                }
                
                // Copy attached file to media directory
                let url: URL = Foundation.URL(fileURLWithPath: "\(path)\(Manager.media)/\(filename.replacingOccurrences(of: " ", with: String.separator))")
                do {
                    if FileManager.default.fileExists(atPath: url.path) {
                        try FileManager.default.trashItem(at: url, resultingItemURL: nil)
                    }
                    try data.write(to: url, options: .atomicWrite)
                } catch {
                    
                    // File copy failed; strip attribute
                    textStorage.removeAttribute(name, range: range)
                    continue
                }
                
                // Replace attachment
                let attachmentString: NSMutableAttributedString = NSMutableAttributedString(string: "")
                if let attachment: PageViewAttachment = PageViewAttachment(path: url.path) {
                    attachmentString.append(NSAttributedString(attachment: attachment))
                }
                textStorage.replaceCharacters(in: range, with: attachmentString)
            }
        }
    }
}
