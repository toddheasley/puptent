//
//  ImageView.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa

class ImageView: NSImageView, NSDraggingDestination {
    var delegate: ImageViewDelegate?
    var URL: NSURL?
    override var image: NSImage? {
        didSet {
            if (self.image == nil) {
                self.URL = nil
            }
            
            // Notify delegate
            self.delegate?.handleImageViewChange(self)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.registerForDraggedTypes(NSImage.imagePasteboardTypes())
    }
    
    override func drawRect(rect: NSRect) {
        super.drawRect(rect)
        
        if (self.active) {
            
        }
    }
    
    private var active: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: NSDraggingSource
    func draggingSession(session: NSDraggingSession, sourceOperationMaskForDraggingContext context: NSDraggingContext) -> NSDragOperation {
        return NSDragOperation.Copy
    }
    
    // MARK: NSDraggingDestination
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        if (NSImage.canInitWithPasteboard(sender.draggingPasteboard())) {
            self.active = true
            return NSDragOperation.Copy
        }
        return NSDragOperation.None
    }
    
    override func draggingExited(sender: NSDraggingInfo?) {
        self.active = false
    }
    
    override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
        self.active = false
        return NSImage.canInitWithPasteboard(sender.draggingPasteboard())
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        if (sender.draggingSource() as? ImageView != self && NSImage.canInitWithPasteboard(sender.draggingPasteboard())) {
            if let URL = NSURL(fromPasteboard: sender.draggingPasteboard()) {
                self.URL = URL
                self.image = NSImage(pasteboard: sender.draggingPasteboard())
                
                // Notify delegate
                self.delegate?.handleImageViewChange(self)
            }
        }
        return true
    }
}

protocol ImageViewDelegate {
    func handleImageViewChange(imageView: ImageView)
}
