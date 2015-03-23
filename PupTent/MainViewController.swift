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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let delegate = NSApplication.sharedApplication().delegate as? AppDelegate {
            delegate.mainViewController = self
        }
        self.siteViewController = SiteViewController(nibName: "Site", bundle: nil)
        self.view.addSubview(self.siteViewController!.view)
        
        // Default to empty state
        self.toggleEmpty(true, animated: false)
        if (self.canForget) {
            
            // Open most recent site
            self.openSite(NSUserDefaults.standardUserDefaults().path, animated: false)
        }
    }
    
    private func openSite(path: String, animated: Bool) {
        var error: NSError?
        let manager = Manager(path: path, error: &error)
        if (error != nil) {
            if let window = self.view.window {
                
                // Suppress error on launch; only show if the application has a window
                var alert: NSAlert = NSAlert()
                alert.messageText = "\(error!.localizedDescription)"
                alert.runModal()
            }
            return
        }
        
        // Remember path
        NSUserDefaults.standardUserDefaults().path = manager!.path
        
        // Configure site view controller
        self.siteViewController!.manager = manager!
        self.toggleEmpty(false, animated: true)
    }
    
    private func toggleEmpty(empty: Bool, animated: Bool) {
        self.siteViewController!.view.hidden = empty
        self.emptyView!.hidden = !empty
    }
    
    // MARK: IBOutlet, IBAction
    @IBOutlet weak var makeNewSiteButton: NSButton?
    @IBOutlet weak var openSiteButton: NSButton?
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
                var alert: NSAlert = NSAlert()
                alert.messageText = "\(error.localizedDescription)"
                alert.runModal()
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
