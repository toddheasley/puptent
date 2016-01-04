//
//  PageRowView.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa

class PageRowView: NSTableRowView {
    private var index: Int = -1
    
    override var interiorBackgroundStyle: NSBackgroundStyle {
        return .Light
    }
    
    override func drawSelectionInRect(dirtyRect: NSRect) {
        NSColor.gridColor().colorWithAlphaComponent(emphasized ? 0.42: 0.21).setFill()
        let path = NSBezierPath(rect: dirtyRect)
        path.fill()
    }
    
    override func drawBackgroundInRect(dirtyRect: NSRect) {
        super.drawBackgroundInRect(dirtyRect)
        
        guard let tableView = superview as? NSTableView where !selected else {
            return
        }
        
        tableView.gridColor.colorWithAlphaComponent(0.7).setFill()
        if (index + 1 < tableView.numberOfRows) {
            NSBezierPath(rect: NSMakeRect(15.0, dirtyRect.size.height - 0.5, dirtyRect.size.width - 15.0, 0.5)).fill()
        }
        if (index > 0) {
            NSBezierPath(rect: NSMakeRect(15.0, 0.0, dirtyRect.size.width - 15.0, 0.5)).fill()
        }
    }
    
    convenience init(index: Int) {
        self.init()
        self.index = index
    }
}
