//
//  BookmarkIconView.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa

class BookmarkIconView: NSImageView {
    private var button: NSButton = NSButton()
    
    override var image: NSImage? {
        didSet{
            button.hidden = image != nil
        }
    }
    
    func chooseImage(sender: AnyObject) {
        let openPanel: NSOpenPanel = NSOpenPanel()
        openPanel.allowedFileTypes = NSImage.imageTypes()
        openPanel.title = "Choose a Bookmark Icon..."
        openPanel.prompt = "Use This Image"
        openPanel.beginWithCompletionHandler{ result in
            if let URL = openPanel.URL, image = NSImage(contentsOfURL: URL) where result == NSFileHandlingPanelOKButton {
                self.image = image
                self.sendAction(self.action, to: self.target)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        wantsLayer = true
        layer?.backgroundColor = NSColor.windowBackgroundColor().CGColor
        
        button.alphaValue = 0.0
        button.target = self
        button.action = #selector(BookmarkIconView.chooseImage(_:))
        addSubview(button)
        pin(button, inset: 0.0)
    }
}
