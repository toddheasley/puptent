//
//  Window.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa

class Window: NSWindow {
    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
