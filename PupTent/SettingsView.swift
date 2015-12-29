//
//  SettingsView.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa
import PupKit

@objc protocol SettingsViewDelegate {
    func settingsViewDidChange(view: SettingsView)
}

class SettingsView: NSView {
    @IBOutlet weak var delegate: SettingsViewDelegate?
    
    override func viewWillDraw() {
        super.viewWillDraw()
        
        wantsLayer = true
        layer?.backgroundColor = NSColor.grayColor().CGColor
    }
}
