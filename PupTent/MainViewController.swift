//
//  MainViewController.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa
import PupKit

class MainViewController: NSViewController {
    @IBOutlet weak var previewButton: NSButton?
    @IBOutlet weak var makeNewSiteButton: NSButton?
    @IBOutlet weak var openSiteButton: NSButton?
    @IBOutlet weak var emptyView: NSView?
    
    @IBAction func preview(sender: AnyObject?) {
        if let manager = self.siteViewController?.manager {
            var URI = manager.site.URI
            if let page = self.siteViewController?.selectedPage.page {
                URI = page.URI
            }
            NSWorkspace.sharedWorkspace().openFile(manager.path + URI)
        }
    }
    
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
                self.showAlert("\(error.localizedDescription)")
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
    
    @IBAction func makeNewPage(sender: AnyObject?) {
        self.siteViewController?.selectNewPage()
    }
    
    @IBAction func deletePage(sender: AnyObject?) {
        if (self.canDeletePage) {
            self.siteViewController?.deleteSelectedPage()
        }
    }
    
    var siteViewController: SiteViewController?
    var canForget: Bool {
        get {
            return !NSUserDefaults.standardUserDefaults().path.isEmpty
        }
    }
    var canDeletePage: Bool {
        get {
            return self.siteViewController?.selectedPage.index >= 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let delegate = NSApplication.sharedApplication().delegate as? AppDelegate {
            delegate.mainViewController = self
        }
        
        self.siteViewController = SiteViewController(nibName: "Site", bundle: nil)
        self.view.addSubview(self.siteViewController!.view)
        
        self.toggleEmpty(true, animated: false)
        if (self.canForget) {
            
            // Open most recent site
            self.openSite(NSUserDefaults.standardUserDefaults().path, animated: false)
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // Remove preview button from view
        self.previewButton?.removeFromSuperview()
        
        if let window = self.view.window as? Window, view = window.titleBarView as NSView! {
            
            // Insert preview button into window title bar
            view.addSubview(self.previewButton!)
            
            self.previewButton!.translatesAutoresizingMaskIntoConstraints = true
            var frame = self.previewButton!.frame
            frame.origin.x = view.bounds.size.width - frame.size.width - 3.0
            frame.origin.y = 8.0
            self.previewButton!.frame = frame
        }
    }
    
    private func openSite(path: String, animated: Bool) {
        var error: NSError?
        let manager = Manager(path: path, error: &error)
        if (error != nil) {
            self.showAlert("\(error!.localizedDescription)")
            return
        }
        
        // Remember path
        NSUserDefaults.standardUserDefaults().path = manager!.path
        
        // Configure site view controller
        self.siteViewController!.manager = manager!
        self.toggleEmpty(false, animated: true)
    }
    
    private func toggleEmpty(empty: Bool, animated: Bool) {
        self.previewButton!.hidden = empty
        self.siteViewController!.view.hidden = empty
        self.emptyView!.hidden = !empty
    }
    
    private func showAlert(text: String) {
        println("Alert: \(text)")
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
