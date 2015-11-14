//
//  MainViewController.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa
import PupKit

class MainViewController: NSViewController {
    var siteViewController: SiteViewController!
    @IBOutlet var emptyView: NSView!
    @IBOutlet var makeNewSiteButton: NSButton!
    @IBOutlet var openExistingSiteButton: NSButton!
    
    var canForget: Bool {
        return !NSUserDefaults.standardUserDefaults().path.isEmpty
    }
    
    private func openSite(path: String, animated: Bool) {
        do {
            let manager = try Manager(path: path)
            
            view.window?.toolbarHidden = false
            siteViewController.view.hidden = false
            
            // Remember path
            NSUserDefaults.standardUserDefaults().path = manager.path
        } catch {
            print((error as NSError).localizedDescription)
            return
        }
    }
    
    @IBAction func forget(sender: AnyObject?) {
        NSUserDefaults.standardUserDefaults().path = ""
        
        view.window?.toolbarHidden = true
        siteViewController.view.hidden = true
    }
    
    @IBAction func makeNewSite(sender: AnyObject?) {
        let openPanel: NSOpenPanel = NSOpenPanel()
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
            do {
                try Manager.pitch(path)
                self.openSite(path, animated: true)
            } catch {
                print((error as NSError).localizedDescription)
            }
        })
    }
    
    @IBAction func openExistingSite(sender: AnyObject?) {
        let openPanel: NSOpenPanel = NSOpenPanel()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let delegate = NSApplication.sharedApplication().delegate as? AppDelegate {
            delegate.mainViewController = self
        }
        
        siteViewController = SiteViewController(nibName: "Site", bundle: nil)
        siteViewController.view.hidden = true
        view.addSubview(siteViewController.view)
        view.pin(siteViewController.view, inset: 0.0)
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.controlBackgroundColor().CGColor
        
        if (canForget) {
            
            // Open most recent site
            openSite(NSUserDefaults.standardUserDefaults().path, animated: false)
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.toolbarHidden = !canForget
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
