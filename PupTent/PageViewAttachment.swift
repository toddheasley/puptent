//
//  PageViewAttachment.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa

class PageViewAttachment: NSTextAttachment {
    private(set) var path: String?
    
    convenience init?(path: String) {
        do {
            self.init(fileWrapper: try NSFileWrapper(URL: NSURL(fileURLWithPath: path), options: .Immediate))
        } catch {
            return nil
        }
        self.path = path
        if let attachmentCell = attachmentCell as? NSTextAttachmentCell {
            self.attachmentCell = PageViewAttachmentCell(imageCell: attachmentCell.image)
        }
    }
}

class PageViewAttachmentCell: NSTextAttachmentCell {
    override func cellFrameForTextContainer(textContainer: NSTextContainer, proposedLineFragment lineFrag: NSRect, glyphPosition position: NSPoint, characterIndex charIndex: Int) -> NSRect {
        guard let textView = textContainer.textView, image = image else {
            return NSZeroRect
        }
        let width: CGFloat = textContainer.size.width - textView.textContainerInset.width
        let scale: CGFloat = image.size.width < width ? 1.0 : width / image.size.width
        return NSMakeRect(0.0, 0.0, width, image.size.height * scale)
    }
    
    override func drawWithFrame(cellFrame: NSRect, inView controlView: NSView?) {
        if let image = image {
            image.drawInRect(cellFrame, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0, respectFlipped: true, hints: nil)
        }
    }
}
