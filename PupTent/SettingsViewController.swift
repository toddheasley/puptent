//
//  SettingsViewController.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa
import PupKit

protocol SettingsViewDelegate {
    func settingsDidChange(settings: Settings)
}

class SettingsViewController: NSViewController, NSTextFieldDelegate {
    var delegate: SettingsViewDelegate?
    private var settings: Settings!
    @IBOutlet weak var bookmarkIconView: NSImageView!
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var twitterNameTextField: NSTextField!
    
    @IBAction func bookmarkIconChanged(sender: AnyObject?) {
        if let URL = settings.bookmarkIconURL, imageView = sender as? NSImageView {
            
            // Move existing bookmark icon to trash
            do {
                try NSFileManager.defaultManager().trashItemAtURL(URL, resultingItemURL: nil)
            } catch { }
            if let image = imageView.image, data = image.TIFFRepresentation {
                
                // Write new bookmark icon file to path
                data.writeToURL(URL, atomically: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //bookmarkIconView.wantsLayer = true
        //bookmarkIconView.layer?.masksToBounds = true
        //bookmarkIconView.layer?.backgroundColor = NSColor.clearColor().CGColor
        //bookmarkIconView.layer?.borderColor = NSColor.clearColor().CGColor
        //bookmarkIconView.layer?.borderWidth = 0.0
        //bookmarkIconView.layer?.cornerRadius = 0.0
        
        if let URL = settings.bookmarkIconURL, image = NSImage(contentsOfURL: URL) {
            //bookmarkIconView.image = image
        }
        //nameTextField.stringValue = settings.name
        //twitterNameTextField.stringValue = settings.twitterName.twitterFormat()
    }
    
    convenience init?(settings: Settings) {
        self.init(nibName: "Settings", bundle: nil)
        self.settings = settings
    }
    
    // MARK: NSTextFieldDelegate
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        settings.name = nameTextField.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        settings.twitterName = twitterNameTextField.stringValue.twitterFormat(false)
        delegate?.settingsDidChange(settings)
        
        twitterNameTextField.stringValue = twitterNameTextField.stringValue.twitterFormat()
        return true
    }
}

struct Settings {
    var name: String = ""
    var twitterName: String = ""
    var bookmarkIconURL: NSURL?
    var stylesheetURL: NSURL?
}
