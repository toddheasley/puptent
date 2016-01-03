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

class SettingsView: NSView, NSTextFieldDelegate, NSTextStorageDelegate {
    private var timer: NSTimer?
    @IBOutlet weak var delegate: SettingsViewDelegate?
    @IBOutlet var bookmarkIconView: BookmarkIconView!
    @IBOutlet var nameTextField: NSTextField!
    @IBOutlet var twitterTextField: NSTextField!
    @IBOutlet var stylesheetTextView: NSTextView!
    
    var path: String? {
        didSet{
            guard let path = path else {
                return
            }
            bookmarkIconView.image = NSImage(contentsOfFile: "\(path)/\(HTML.bookmarkIconURI)")
            if (NSFileManager.defaultManager().fileExistsAtPath("\(path)/\(HTML.stylesheetURI)")) {
                do {
                    stylesheetTextView.string = try String(contentsOfFile: "\(path)/\(HTML.stylesheetURI)", encoding: NSUTF8StringEncoding)
                } catch let error as NSError {
                    NSAlert(message: error.localizedFailureReason, description: error.localizedDescription, buttons: [
                        "Cancel"
                    ]).beginSheetModalForWindow(window)
                }
            }
            stylesheetTextView.scrollRangeToVisible(NSMakeRange(0, 0)) // Reset scroll position
            guard let string = stylesheetTextView.string where !string.isEmpty else {
                stylesheetTextView.string = "/* CSS */"
                return
            }
        }
    }
    
    @IBAction func bookmarkIconDidChange(sender: AnyObject?) {
        guard let path = path, view = sender as? NSImageView else {
            return
        }
        let URL = NSURL(fileURLWithPath: "\(path)/\(HTML.bookmarkIconURI)")
        do {
            if (NSFileManager.defaultManager().fileExistsAtPath(URL.path!)) {
                try NSFileManager.defaultManager().trashItemAtURL(URL, resultingItemURL: nil)
            }
        } catch let error as NSError {
            NSAlert(message: error.localizedFailureReason, description: error.localizedDescription, buttons: [
                "Cancel",
                "Open in Finder"
            ]).beginSheetModalForWindow(window){ response in
                self.path = path
                if (response != NSAlertFirstButtonReturn) {
                    NSWorkspace.sharedWorkspace().openURL(URL)
                }
            }
        }
        if let image = view.image {
            image.TIFFRepresentation?.writeToURL(URL, atomically: true)
        }
    }
    
    func stylesheetTextViewDidChange() {
        guard let path = path else {
            return
        }
        stylesheetTextView.string?.trim().dataUsingEncoding(NSUTF8StringEncoding)?.writeToFile("\(path)/\(HTML.stylesheetURI)", atomically: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        wantsLayer = true
        layer?.backgroundColor = NSColor.textBackgroundColor().CGColor
        
        stylesheetTextView.textStorage?.delegate = self
        stylesheetTextView.textContainerInset = NSMakeSize(8.0, 10.0)
        stylesheetTextView.font = NSFont(name: "Menlo", size: 11.0)
        stylesheetTextView.textColor = NSColor.scrollBarColor()
    }
    
    // MARK: NSTextFieldDelegate
    override func controlTextDidEndEditing(notification: NSNotification) {
        if let control = notification.object as? NSTextField {
            switch control {
            case nameTextField:
                control.stringValue = control.stringValue.trim()
            case twitterTextField:
                control.stringValue = control.stringValue.twitterFormat()
            default:
                break
            }
        }
        delegate?.settingsViewDidChange(self)
    }
    
    // MARK: NSTextStorageDelegate
    func textStorage(textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "stylesheetTextViewDidChange", userInfo: nil, repeats: false)
    }
}
