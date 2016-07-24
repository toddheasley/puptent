//
//  PageCellView.swift
//  PupTent
//
//  (c) 2016 @toddheasley
//

import Cocoa
import PupKit

@objc protocol PageCellViewDelegate {
    func pageCellViewDidChange(_ view: PageCellView)
}

class PageCellView: NSTableCellView, NSTextFieldDelegate {
    @IBOutlet weak var delegate: PageCellViewDelegate?
    @IBOutlet var secondaryTextField: NSTextField!
    @IBOutlet var button: PageCellButton!
    
    @IBAction func toggleButton(_ sender: AnyObject?) {
        button.state = button.state
        delegate?.pageCellViewDidChange(self)
    }
    
    // MARK: NSTextFieldDelegate
    override func controlTextDidEndEditing(_ notification: Notification) {
        if let textField = textField, let control = notification.object as? NSTextField {
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
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        guard let control = control as? NSTextField, control == textField && commandSelector == #selector(NSResponder.cancelOperation(_:)) else {
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
