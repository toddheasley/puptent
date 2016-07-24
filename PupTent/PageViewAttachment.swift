//
//  PageViewAttachment.swift
//  PupTent
//
//  (c) 2016 @toddheasley
//

import Cocoa

class PageViewAttachment: NSTextAttachment {
    private(set) var path: String?
    
    convenience init?(path: String) {
        do {
            self.init(fileWrapper: try FileWrapper(url: URL(fileURLWithPath: path), options: .immediate))
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
    override func cellFrame(for textContainer: NSTextContainer, proposedLineFragment lineFrag: NSRect, glyphPosition position: NSPoint, characterIndex charIndex: Int) -> NSRect {
        guard let textView = textContainer.textView, let image = image else {
            return NSZeroRect
        }
        let imageSize = image.size.width < 64.0 ? image.size : NSMakeSize(image.size.width / 2.0, image.size.height / 2.0)
        var width: CGFloat = textContainer.size.width - textView.textContainerInset.width
        let scale: CGFloat = imageSize.width <= width ? 1.0 : width / imageSize.width
        if (imageSize.width < width) {
            width = imageSize.width
        }
        return NSMakeRect(0.0, 0.0, width, imageSize.height * scale)
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        if let image = image {
            image.draw(in: cellFrame, from: NSZeroRect, operation: .sourceOver, fraction: 1.0, respectFlipped: true, hints: nil)
        }
    }
}
