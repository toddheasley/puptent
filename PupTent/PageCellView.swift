//
//  PageCellView.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa

class PageCellView: NSTableCellView, NSTextFieldDelegate {
    @IBOutlet weak var URITextField: NSTextField?
    @IBOutlet weak var indexButton: NSButton?
    
    @IBAction func toggleIndex(sender: AnyObject?) {
        self.index = !self.index
        
        // Notify delegate
        self.delegate?.handlePageCellViewChange(self)
    }
    
    var delegate: PageCellViewDelegate?
    var index: Bool = false {
        didSet {
            if (self.index) {
                self.indexButton!.image = NSImage(named: "NSStatusAvailable")
            } else {
                self.indexButton!.image = NSImage(named: "NSStatusNone")
            }
        }
    }
    
    // MARK: NSTextFieldDelegate
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if let textField = control as? NSTextField {
            if (textField == self.textField!) {
                textField.stringValue = textField.stringValue.strip()
                if (self.URITextField!.stringValue.isEmpty) {
                    
                    // Suggest default URI
                    self.URITextField!.stringValue = textField.stringValue.toURIFormat()
                }
                
            } else {
                textField.stringValue = textField.stringValue.toURIFormat()
            }
            
            // Notify delegate
            self.delegate?.handlePageCellViewChange(self)
        }
        return true
    }
}

class PageSectionCellView: NSTableCellView, NSTextFieldDelegate {
    var delegate: PageCellViewDelegate?
    
    // MARK: NSTextFieldDelegate
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if let textField = control as? NSTextField {
            
            // Notify delegate
            self.delegate?.handlePageCellViewChange(self)
        }
        return true
    }
}

protocol PageCellViewDelegate {
    func handlePageCellViewChange(pageCellView: NSTableCellView)
}
