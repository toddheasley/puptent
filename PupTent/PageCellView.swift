//
//  PageCellView.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa
import PupKit

@objc protocol PageCellViewDelegate {
    func pageCellViewDidChange(view: PageCellView)
}

class PageCellView: NSTableCellView, NSTextFieldDelegate {
    @IBOutlet weak var delegate: PageCellViewDelegate?
    @IBOutlet var secondaryTextField: NSTextField!
    @IBOutlet var button: PageCellButton!
    
    @IBAction func toggleButton(sender: AnyObject?) {
        button.state = button.state
        delegate?.pageCellViewDidChange(self)
    }
    
    // MARK: NSTextFieldDelegate
    override func controlTextDidEndEditing(notification: NSNotification) {
        if let textField = textField, control = notification.object as? NSTextField {
            switch control {
            case textField:
                control.stringValue = control.stringValue.trim()
                if (secondaryTextField.stringValue.isEmpty) {
                    secondaryTextField.stringValue = control.stringValue.URIFormat
                }
            case secondaryTextField:
                if (control.stringValue.isEmpty) {
                    control.stringValue = textField.stringValue
                }
                control.stringValue = control.stringValue.URIFormat
            default:
                break
            }
        }
        delegate?.pageCellViewDidChange(self)
    }
    
    func control(control: NSControl, textView: NSTextView, doCommandBySelector commandSelector: Selector) -> Bool {
        guard let control = control as? NSTextField where control == textField && commandSelector == "cancelOperation:" else {
            return false
        }
        
        // Handle escape/cancel
        control.resignFirstResponder()
        delegate?.pageCellViewDidChange(self)
        return true
    }
}

class PageCellButton: NSButton {
    override var state: Int {
        didSet{
            image = state == 1 ? NSImage(named: "NSStatusAvailable") : NSImage(named: "NSStatusNone")
        }
    }
}
