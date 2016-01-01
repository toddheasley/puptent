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

class SettingsView: NSView, NSTextFieldDelegate {
    @IBOutlet weak var delegate: SettingsViewDelegate?
    @IBOutlet var bookmarkIconImageView: NSImageView!
    @IBOutlet var nameTextField: NSTextField!
    @IBOutlet var twitterTextField: NSTextField!
    
    var path: String? {
        didSet{
            bookmarkIconImageView.image = nil
            if let path = path, image = NSImage(contentsOfFile: "\(path)/\(HTML.bookmarkIconURI)") {
                bookmarkIconImageView.image = image
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
}
