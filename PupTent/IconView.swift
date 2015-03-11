//
//  ImageView.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa

class IconView: NSImageView, NSDraggingDestination {
    var path: String? {
        didSet {
            if let path = self.path, URL = NSURL(fileURLWithPath: path) {
                self.image = NSImage(contentsOfURL: URL)
            }
        }
    }
    override var image: NSImage? {
        didSet {
            if (self.image == nil) {
                // self.image = NSImage(named: "NSBookmarksTemplate")
                if let path = self.path, URL = NSURL(fileURLWithPath: path) {
                    NSFileManager.defaultManager().trashItemAtURL(URL, resultingItemURL: nil, error: nil)
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.registerForDraggedTypes([NSPasteboardTypePNG])
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.wantsLayer = true
        
        self.layer?.masksToBounds = true
        self.layer?.borderColor = NSColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
        self.layer?.borderWidth = 1.0
        self.layer?.cornerRadius = 5.0
    }
    
    // MARK: NSDraggingDestination
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        if (NSImage.canInitWithPasteboard(sender.draggingPasteboard())) {
            return NSDragOperation.Copy
        }
        return NSDragOperation.None
    }
    
    override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
        return NSImage.canInitWithPasteboard(sender.draggingPasteboard())
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        if (sender.draggingSource() as? IconView != self && NSImage.canInitWithPasteboard(sender.draggingPasteboard())) {
            if let path = self.path, URL = NSURL(fileURLWithPath: path), pasteboardURL = NSURL(fromPasteboard: sender.draggingPasteboard()) {
                
                // Move existing bookmark icon to trash
                NSFileManager.defaultManager().trashItemAtURL(URL, resultingItemURL: nil, error: nil)
                
                // Copy new bookmark icon
                var error: NSError?
                NSFileManager.defaultManager().copyItemAtURL(pasteboardURL, toURL: URL, error: &error)
                if let error = error {
                    
                    // Copy failed
                    return false
                }
                self.image = NSImage(contentsOfURL: URL)
            }
            return true
        }
        return false
    }
}
