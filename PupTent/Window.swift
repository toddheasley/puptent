//
//  Window.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa

class Window: NSWindow {
    var titleBarView: NSView? {
        get {
            if let view = self.contentView.superview, subviews = view?.subviews {
                return subviews[1] as? NSView
            }
            return nil
        }
    }
    
    func toggleToolbar(hidden: Bool) {
        self.toolbar?.showsBaselineSeparator = !hidden
        self.titlebarAppearsTransparent = hidden
    }
    
    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        self.titleVisibility = NSWindowTitleVisibility.Hidden
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
