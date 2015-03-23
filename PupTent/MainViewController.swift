//
//  MainViewController.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa
import PupKit

class MainViewController: NSViewController {
    var siteViewController: SiteViewController?
    var canForget: Bool {
        get {
            return !NSUserDefaults.standardUserDefaults().path.isEmpty
        }
    }
    var empty: Bool {
        get {
            if let emptyView = self.emptyView {
                return !emptyView.hidden
            }
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let delegate = NSApplication.sharedApplication().delegate as? AppDelegate {
            delegate.mainViewController = self
        }
        
        self.emptyView!.wantsLayer = true
        self.emptyView!.layer?.backgroundColor = NSColor.whiteColor().CGColor
        
        self.siteViewController = SiteViewController(nibName: "Site", bundle: nil)
        self.view.addSubview(self.siteViewController!.view)
        
        // Default to empty state
        self.toggleEmpty(true, animated: false)
        if (self.canForget) {
            
            // Open most recent site
            self.openSite(NSUserDefaults.standardUserDefaults().path, animated: false)
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.toggleEmpty(self.empty, animated: false)
    }
    
    private func openSite(path: String, animated: Bool) {
        var error: NSError?
        let manager = Manager(path: path, error: &error)
        if (error != nil) {
            self.alert(error!.localizedDescription)
            return
        }
        
        // Remember path
        NSUserDefaults.standardUserDefaults().path = manager!.path
        
        // Configure site view controller
        self.siteViewController!.manager = manager!
        self.toggleEmpty(false, animated: true)
    }
    
    private func toggleEmpty(empty: Bool, animated: Bool) {
        if let window = self.view.window as? Window {
            window.toggleToolbar(empty)
        }
        self.siteViewController!.view.hidden = empty
        self.emptyView!.hidden = !empty
    }
    
    private func alert(text: String) {
        self.alertLabel?.hidden = text.isEmpty
        self.alertLabel?.stringValue = "\(text)"
        5.0.delay {
            self.alertLabel?.hidden = true
            self.alertLabel?.stringValue = ""
        }
    }
    
    // MARK: IBOutlet, IBAction
    @IBOutlet weak var makeNewSiteButton: NSButton?
    @IBOutlet weak var openSiteButton: NSButton?
    @IBOutlet weak var alertLabel: NSTextField?
    @IBOutlet weak var emptyView: NSView?
    
    @IBAction func forget(sender: AnyObject?) {
        self.toggleEmpty(true, animated: true)
        NSUserDefaults.standardUserDefaults().path = ""
        self.siteViewController?.manager = nil
    }
    
    @IBAction func makeNewSite(sender: AnyObject?) {
        var openPanel: NSOpenPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.title = "Choose an Empty Folder..."
        openPanel.prompt = "Use This Folder"
        openPanel.beginWithCompletionHandler( { (result) -> Void in
            if result != NSFileHandlingPanelOKButton {
                return
            }
            let path = openPanel.URL!.path! + "/"
            if let error = Manager.pitch(path) as NSError! {
                self.alert(error.localizedDescription)
                return
            }
            self.openSite(path, animated: true)
        })
    }
    
    @IBAction func openExistingSite(sender: AnyObject?) {
        var openPanel: NSOpenPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.title = "Choose an Existing Site..."
        openPanel.beginWithCompletionHandler( { (result) -> Void in
            if result != NSFileHandlingPanelOKButton {
                return
            }
            self.openSite(openPanel.URL!.path! + "/", animated: true)
        })
    }
}

extension NSUserDefaults {
    var path: String {
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue as NSString, forKey: "path")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            if let path: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("path") {
                return path as! String
            }
            return ""
        }
    }
}
