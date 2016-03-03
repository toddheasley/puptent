//
//  Window.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa

class Window: NSWindow {
    @IBOutlet var pathLabel: NSButton!
    @IBOutlet var settingsButton: NSButton!
    
    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, `defer` flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        titleVisibility = NSWindowTitleVisibility.Hidden
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension NSWindow {
    var titleBar: NSView? {
        guard let _ = contentView, _ = contentView!.superview else {
            return nil
        }
        return contentView!.superview!.subviews[1]
    }
    
    var toolbarHidden: Bool {
        set {
            toolbar?.showsBaselineSeparator = !newValue
            toolbar?.visible = !newValue
            titlebarAppearsTransparent = newValue
        }
        get {
            return titlebarAppearsTransparent
        }
    }
}
