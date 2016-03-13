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
    private var timer: NSTimer?
    @IBOutlet weak var delegate: SettingsViewDelegate?
    @IBOutlet var bookmarkIconView: BookmarkIconView!
    @IBOutlet var nameTextField: NSTextField!
    @IBOutlet var twitterTextField: NSTextField!
    @IBOutlet var twitterTestButton: NSButton!
    @IBOutlet var fontPopUpButton: NSPopUpButton!
    @IBOutlet var backgroundColorWell: NSColorWell!
    @IBOutlet var textColorWell: NSColorWell!
    @IBOutlet var linkColorWell: NSColorWell!
    @IBOutlet var visitedLinkColorWell: NSColorWell!
    
    var nameText: String {
        set{
            nameTextField.stringValue = newValue.trim()
        }
        get{
            return nameTextField.stringValue.trim()
        }
    }
    
    var twitterText: String {
        set{
            twitterTextField.stringValue = newValue.twitterFormat()
            twitterTestButton.enabled = !twitterTextField.stringValue.twitterFormat(false).isEmpty
            twitterTestButton.image = NSImage(named: "NSStatusNone")
            twitterTestButton.title = "Test"
        }
        get{
            return twitterTextField.stringValue.twitterFormat(false)
        }
    }
    
    var bookmarkIconPath: String? {
        didSet{
            guard let bookmarkIconPath = bookmarkIconPath else {
                bookmarkIconView.image = nil
                return
            }
            bookmarkIconView.image = NSImage(contentsOfURL: NSURL.fileURLWithPath(bookmarkIconPath))
        }
    }
    
    var stylesheetPath: String? {
        didSet{
            var stylesheet = CSS()
            if let stylesheetPath = stylesheetPath, data = NSData(contentsOfURL: NSURL.fileURLWithPath(stylesheetPath)) {
                stylesheet = CSS(data: data)
            }
            switch stylesheet.font {
            case .Serif:
                fontPopUpButton.selectItemAtIndex(0)
            case .Sans:
                fontPopUpButton.selectItemAtIndex(1)
            case .Mono:
                fontPopUpButton.selectItemAtIndex(2)
            }
            if let backgroundColor = NSColor(string: stylesheet.backgroundColor) {
                backgroundColorWell.color = backgroundColor
            }
            if let textColor = NSColor(string: stylesheet.textColor) {
                textColorWell.color = textColor
            }
            if let linkColor = NSColor(string: stylesheet.linkColor.link) {
                linkColorWell.color = linkColor
            }
            if let visitedLinkColor = NSColor(string: stylesheet.linkColor.visited) {
                visitedLinkColorWell.color = visitedLinkColor
            }
        }
    }
    
    func makeNewStylesheet() {
        guard let stylesheetPath = stylesheetPath else {
            return
        }
        let stylesheet = CSS()
        switch fontPopUpButton.indexOfSelectedItem {
        case 1:
            stylesheet.font = .Sans
        case 2:
            stylesheet.font = .Mono
        default:
            stylesheet.font = .Serif
        }
        stylesheet.backgroundColor = backgroundColorWell.color.string
        stylesheet.textColor = textColorWell.color.string
        stylesheet.linkColor.link = linkColorWell.color.string
        stylesheet.linkColor.visited = visitedLinkColorWell.color.string
        stylesheet.generate{ data in
            data.writeToURL(NSURL.fileURLWithPath(stylesheetPath), atomically: true)
        }
    }
    
    @IBAction func testTwitter(sender: AnyObject?) {
        guard let URL = NSURL(string: "https://twitter.com/\(twitterText)") where !twitterText.isEmpty else {
            return
        }
        if (twitterTestButton.title == "View") {
            NSWorkspace.sharedWorkspace().openURL(URL)
            return
        }
        self.twitterTestButton.image = NSImage(named: "NSStatusNone")
        NSURLSession.sharedSession().dataTaskWithURL(URL){ data, response, error in
            guard let response = response as? NSHTTPURLResponse where response.statusCode == 200 else {
                self.twitterTestButton.image = NSImage(named: "NSStatusUnavailable")
                return
            }
            dispatch_async(dispatch_get_main_queue()){
                self.twitterTestButton.image = NSImage(named: "NSStatusAvailable")
                self.twitterTestButton.title = "View"
            }
        }.resume()
    }
    
    @IBAction func bookmarkIconDidChange(sender: AnyObject?) {
        guard let path = bookmarkIconPath, sender = sender as? NSImageView else {
            return
        }
        let URL = NSURL(fileURLWithPath: path)
        do {
            if (NSFileManager.defaultManager().fileExistsAtPath(URL.path!)) {
                try NSFileManager.defaultManager().trashItemAtURL(URL, resultingItemURL: nil)
            }
        } catch let error as NSError {
            NSAlert(message: error.localizedFailureReason, description: error.localizedDescription, buttons: [
                "Cancel",
                "Open in Finder"
            ]).beginSheetModalForWindow(window){ response in
                if (response != NSAlertFirstButtonReturn) {
                    NSWorkspace.sharedWorkspace().openURL(URL)
                }
            }
        }
        if let image = sender.image {
            image.TIFFRepresentation?.writeToURL(URL, atomically: true)
        }
    }
    
    @IBAction func fontDidChange(sender: AnyObject?) {
        makeNewStylesheet()
    }
    
    @IBAction func colorDidChange(sender: AnyObject?) {
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(SettingsView.makeNewStylesheet), userInfo: nil, repeats: false)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        wantsLayer = true
        layer?.backgroundColor = NSColor.controlBackgroundColor().CGColor
    }
    
    // MARK: NSTextFieldDelegate
    override func controlTextDidChange(obj: NSNotification) {
        guard let control = obj.object as? NSTextField where control == twitterTextField else {
            return
        }
        twitterTestButton.enabled = !twitterTextField.stringValue.twitterFormat(false).isEmpty
        twitterTestButton.image = NSImage(named: "NSStatusNone")
        twitterTestButton.title = "Test"
    }
    
    override func controlTextDidEndEditing(notification: NSNotification) {
        guard let control = notification.object as? NSTextField else {
            return
        }
        switch control {
        case nameTextField:
            control.stringValue = control.stringValue.trim()
        case twitterTextField:
            control.stringValue = control.stringValue.twitterFormat()
        default:
            return
        }
        delegate?.settingsViewDidChange(self)
    }
}

extension NSColor {
    var string: String {
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let hex:Int = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255) << 0
        return NSString(format:"#%06x", hex).uppercaseString as String
    }
    
    convenience init?(string: String) {
        if (!string.hasPrefix("#") || string.characters.count != 7) {
            return nil
        }
        var hex:UInt32 = 0
        NSScanner(string: string.replace("#", "")).scanHexInt(&hex)
        self.init(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0, green: CGFloat((hex & 0x00FF00) >> 8) / 255.0, blue: CGFloat(hex & 0x00FF) / 255.0, alpha: 1.0)
    }
}
