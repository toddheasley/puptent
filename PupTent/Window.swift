//
//  Window.swift
//  PupTent
//
//  (c) 2016 @toddheasley
//

import Cocoa

class Window: NSWindow {
    @IBOutlet var pathLabel: NSButton!
    @IBOutlet var settingsButton: NSButton!
    
    override init(contentRect: NSRect, styleMask aStyle: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        titleVisibility = .hidden
    }
}

extension NSWindow {
    var titleBar: NSView? {
        guard let _ = contentView, let _ = contentView!.superview else {
            return nil
        }
        return contentView!.superview!.subviews[1]
    }
    
    var toolbarHidden: Bool {
        set {
            toolbar?.showsBaselineSeparator = !newValue
            toolbar?.isVisible = !newValue
            titlebarAppearsTransparent = newValue
        }
        get {
            return titlebarAppearsTransparent
        }
    }
}
