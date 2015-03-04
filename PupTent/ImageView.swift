//
//  ImageView.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa

protocol ImageViewDelegate {
    func imageViewDidChange(imageView: ImageView)
}

class ImageView: NSImageView, NSDraggingDestination {
    var delegate: ImageViewDelegate?
    
    override var image: NSImage? {
        didSet {
            if (self.image == nil) {
                
            }
            
            // Notify delegate
            self.delegate?.imageViewDidChange(self)
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
            self.image = NSImage(pasteboard: sender.draggingPasteboard())
            
            if let name = NSURL(fromPasteboard: sender.draggingPasteboard())?.lastPathComponent?.stringByDeletingPathExtension {
                println("\(name)")
            }
            
            // Notify delegate
            self.delegate?.imageViewDidChange(self)
        }
        return true
    }
}
