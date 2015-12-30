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
}
