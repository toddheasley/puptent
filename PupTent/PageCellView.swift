//
//  PageCellView.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa
import AVFoundation
import AVKit
import PupKit

class PageCellView: NSTableCellView, NSTextFieldDelegate {
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
    
    // MARK: IBOutlet, IBAction
    @IBOutlet weak var URITextField: NSTextField?
    @IBOutlet weak var indexButton: NSButton?
    
    @IBAction func toggleIndex(sender: AnyObject?) {
        self.index = !self.index
        
        // Notify delegate
        self.delegate?.handlePageCellViewChange(self)
    }
}

class PageSectionCellView: NSTableCellView, NSTextFieldDelegate {
    var delegate: PageCellViewDelegate?
    var content: AnyObject? {
        set {
            var frame = self.frame
            self.textField!.hidden = true
            self.textField!.stringValue = ""
            self.imageView!.hidden = true
            self.imageView!.image = nil
            if let image = newValue as? NSImage {
                frame.size.height = image.size.height
                if (image.size.width > self.imageView!.frame.size.width) {
                    frame.size.height = self.imageView!.frame.size.width * (image.size.height / image.size.width)
                }
                self.imageView!.unregisterDraggedTypes()
                self.imageView!.image = image
                self.imageView!.hidden = false
            } else if let mediaPlayer = newValue as? AVPlayer {
                
                // TODO: Display media file in AVPlayerView
                
            } else {
                if let text = newValue as? String {
                    self.textField!.stringValue = text
                }
                
                // Calculate text field height
                frame.size.height = self.textField!.sizeThatFits(CGSizeMake(self.textField!.frame.size.width, maximumTextFieldHeight)).height
                self.textField!.hidden = false
            }
            frame.size.height += (self.verticalSpaceConstraint!.constant * 2.0)
            self.frame = frame
        }
        get {
            if let image = self.imageView!.image {
                return image
            } else if (!self.textField!.stringValue.isEmpty) {
                return self.textField?.stringValue
            }
            return nil
        }
    }
    var editing: Bool = false
    private let maximumTextFieldHeight: CGFloat = 10000.0
    
    // MARK: NSTextFieldDelegate
    func control(control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        self.editing = true
        return true
    }
    
    override func controlTextDidChange(obj: NSNotification) {
        let textField = NSTextField(frame: self.textField!.frame)
        textField.font = self.textField!.font
        textField.stringValue = self.textField!.stringValue
        
        let height: CGFloat = textField.sizeThatFits(CGSizeMake(self.textField!.frame.size.width, maximumTextFieldHeight)).height + (self.verticalSpaceConstraint!.constant * 2.0)
        if (height != self.frame.size.height + 5.0) {
            
            // Notify delegate
            self.delegate?.handlePageCellViewChange(self)
        }
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        self.editing = false
        if let textField = control as? NSTextField {
            
            // Notify delegate
            if (textField.stringValue.isEmpty) {
                self.delegate?.handlePageCellViewDelete(self)
            } else {
                self.delegate?.handlePageCellViewChange(self)
            }
        }
        return true
    }
    
    // MARK: IBOutlet, IBAction
    @IBOutlet weak var verticalSpaceConstraint: NSLayoutConstraint?
    
    @IBAction func deleteImage(sender: AnyObject?) {
        
        // Notify delegate
        self.delegate?.handlePageCellViewDelete(self)
    }
}

protocol PageCellViewDelegate {
    func handlePageCellViewChange(pageCellView: NSTableCellView)
    func handlePageCellViewDelete(pageCellView: NSTableCellView)
}
