import Cocoa
import PupKit

@objc protocol SettingsViewDelegate {
    func settingsViewDidChange(_ view: SettingsView)
}

class SettingsView: NSView, NSTextFieldDelegate {
    private var timer: Timer?
    @IBOutlet weak var delegate: SettingsViewDelegate?
    @IBOutlet var bookmarkIconView: BookmarkIconView!
    @IBOutlet var nameTextField: NSTextField!
    @IBOutlet var urlTextField: NSTextField!
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
    
    var urlText: String {
        set{
            urlTextField.stringValue = newValue.urlFormat
            
        }
        get{
            return urlTextField.stringValue
        }
    }
    
    var twitterText: String {
        set{
            twitterTextField.stringValue = newValue.twitterFormat()
            twitterTestButton.isEnabled = !twitterTextField.stringValue.twitterFormat(format: false).isEmpty
            twitterTestButton.image = NSImage(named: NSImage.Name(rawValue: "NSStatusNone"))
            twitterTestButton.title = "Test"
        }
        get{
            return twitterTextField.stringValue.twitterFormat(format: false)
        }
    }
    
    var bookmarkIconPath: String? {
        didSet{
            guard let bookmarkIconPath: String = bookmarkIconPath else {
                bookmarkIconView.image = nil
                return
            }
            bookmarkIconView.image = NSImage(contentsOf: URL(fileURLWithPath: bookmarkIconPath))
        }
    }
    
    var stylesheetPath: String? {
        didSet{
            var stylesheet: CSS = CSS()
            if let stylesheetPath: String = stylesheetPath, let data: Data = try? Data(contentsOf: URL(fileURLWithPath: stylesheetPath)) {
                stylesheet = CSS(data: data)
            }
            switch stylesheet.font {
            case .serif:
                fontPopUpButton.selectItem(at: 0)
            case .sans:
                fontPopUpButton.selectItem(at: 1)
            case .mono:
                fontPopUpButton.selectItem(at: 2)
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
    
    @objc func makeNewStylesheet() {
        guard let stylesheetPath = stylesheetPath else {
            return
        }
        var stylesheet: CSS = CSS()
        switch fontPopUpButton.indexOfSelectedItem {
        case 1:
            stylesheet.font = .sans
        case 2:
            stylesheet.font = .mono
        default:
            stylesheet.font = .serif
        }
        stylesheet.backgroundColor = backgroundColorWell.color.string
        stylesheet.textColor = textColorWell.color.string
        stylesheet.linkColor.link = linkColorWell.color.string
        stylesheet.linkColor.visited = visitedLinkColorWell.color.string
        stylesheet.generate{ data in
            try? data.write(to: URL(fileURLWithPath: stylesheetPath), options: .atomicWrite)
        }
    }
    
    @IBAction func testURL(_ sender: AnyObject) {
        
    }
    
    @IBAction func testTwitter(_ sender: AnyObject?) {
        guard let url: URL = URL(string: "https://twitter.com/\(twitterText)"), !twitterText.isEmpty else {
            return
        }
        if twitterTestButton.title == "View" {
            NSWorkspace.shared.open(url)
            return
        }
        self.twitterTestButton.image = NSImage(named: NSImage.Name(rawValue: "NSStatusNone"))
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard let response: HTTPURLResponse = response as? HTTPURLResponse, response.statusCode == 200 else {
                    self.twitterTestButton.image = NSImage(named: NSImage.Name(rawValue: "NSStatusUnavailable"))
                    return
                }
                self.twitterTestButton.image = NSImage(named: NSImage.Name(rawValue: "NSStatusAvailable"))
                self.twitterTestButton.title = "View"
            }
        }.resume()
    }
    
    @IBAction func bookmarkIconDidChange(_ sender: AnyObject?) {
        guard let path: String = bookmarkIconPath, let sender: NSImageView = sender as? NSImageView else {
            return
        }
        let url: URL = URL(fileURLWithPath: path)
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.trashItem(at: url, resultingItemURL: nil)
            }
        } catch {
            NSAlert(message: (error as NSError).localizedFailureReason, description: error.localizedDescription, buttons: [
                "Cancel",
                "Open in Finder"
            ]).beginSheetModal(for: window!){ response in
                if response != .alertFirstButtonReturn {
                    NSWorkspace.shared.open(url)
                }
            }
        }
        if let image: NSImage = sender.image {
            let _ = try? image.tiffRepresentation?.write(to: url, options: .atomicWrite)
        }
    }
    
    @IBAction func fontDidChange(_ sender: AnyObject?) {
        makeNewStylesheet()
    }
    
    @IBAction func colorDidChange(_ sender: AnyObject?) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SettingsView.makeNewStylesheet), userInfo: nil, repeats: false)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        wantsLayer = true
        layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
    }
    
    // MARK: NSTextFieldDelegate
    override func controlTextDidChange(_ obj: Notification) {
        guard let control = obj.object as? NSTextField, control == twitterTextField else {
            return
        }
        twitterTestButton.isEnabled = !twitterTextField.stringValue.twitterFormat(format: false).isEmpty
        twitterTestButton.image = NSImage(named: NSImage.Name(rawValue: "NSStatusNone"))
        twitterTestButton.title = "Test"
    }
    
    override func controlTextDidEndEditing(_ notification: Notification) {
        guard let control = notification.object as? NSTextField else {
            return
        }
        switch control {
        case nameTextField:
            control.stringValue = control.stringValue.trim()
        case urlTextField:
            control.stringValue = control.stringValue.urlFormat
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
        let hex: Int = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255) << 0
        return NSString(format:"#%06x", hex).uppercased as String
    }
    
    convenience init?(string: String) {
        if !string.hasPrefix("#") || string.count != 7 {
            self.init()
            return nil
        }
        var hex: UInt32 = 0
        Scanner(string: string.replace(string: "#", "")).scanHexInt32(&hex)
        self.init(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0, green: CGFloat((hex & 0x00FF00) >> 8) / 255.0, blue: CGFloat(hex & 0x00FF) / 255.0, alpha: 1.0)
    }
}
