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
    @IBOutlet var emptyView: NSView!
    @IBOutlet var makeNewSiteButton: NSButton!
    @IBOutlet var openExistingSiteButton: NSButton!
    
    var canForget: Bool {
        return !NSUserDefaults.standardUserDefaults().path.isEmpty
    }
    
    private func openSite(path: String, animated: Bool) {
        do {
            let manager = try Manager(path: path)
            
            siteViewController = SiteViewController(manager: manager)
            guard let siteViewController = siteViewController else {
                return
            }
            view.addSubview(siteViewController.view)
            view.pin(siteViewController.view, inset: 0.0)
            (view.window as? Window)?.pathLabel.title = (manager.path as NSString).stringByAbbreviatingWithTildeInPath
            view.window?.toolbarHidden = false
            
            // Remember path
            NSUserDefaults.standardUserDefaults().path = manager.path
        } catch let error as NSError {
            forget(self)
            NSAlert(message: error.localizedFailureReason, description: error.localizedDescription, buttons: [
                "Cancel",
                "Open in Finder"
            ]).runModal{ response in
                if (response == NSAlertFirstButtonReturn) {
                    return
                }
                NSWorkspace.sharedWorkspace().openURL(NSURL(fileURLWithPath: path))
            }
        }
    }
    
    @IBAction func forget(sender: AnyObject?) {
        view.window?.toolbarHidden = true
        siteViewController?.view.removeFromSuperview()
        siteViewController = nil
        
        // Forget path
        NSUserDefaults.standardUserDefaults().path = ""
    }
    
    @IBAction func makeNewSite(sender: AnyObject?) {
        let openPanel: NSOpenPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.title = "Choose an Empty Folder..."
        openPanel.prompt = "Use This Folder"
        openPanel.beginWithCompletionHandler{ result in
            if result != NSFileHandlingPanelOKButton {
                return
            }
            let path = openPanel.URL!.path! + "/"
            do {
                try Manager.pitch(path)
                self.openSite(path, animated: true)
            } catch let error as NSError {
                NSAlert(message: error.localizedFailureReason, description: error.localizedDescription, buttons: [
                    "Cancel",
                    "Open in Finder"
                ]).runModal{ response in
                    if (response == NSAlertFirstButtonReturn) {
                        return
                    }
                    NSWorkspace.sharedWorkspace().openURL(NSURL(fileURLWithPath: path))
                }
            }
        }
    }
    
    @IBAction func openExistingSite(sender: AnyObject?) {
        let openPanel: NSOpenPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.title = "Choose an Existing Site..."
        openPanel.beginWithCompletionHandler{ result in
            if result != NSFileHandlingPanelOKButton {
                return
            }
            self.openSite(openPanel.URL!.path! + "/", animated: true)
        }
    }
    
    @IBAction func openInFinder(sender: AnyObject?) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(fileURLWithPath: NSUserDefaults.standardUserDefaults().path))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let delegate = NSApplication.sharedApplication().delegate as? AppDelegate {
            delegate.mainViewController = self
        }
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.controlBackgroundColor().CGColor
        
        if (canForget) {
            
            // Open most recent site
            openSite(NSUserDefaults.standardUserDefaults().path, animated: false)
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        (view.window as? Window)?.pathLabel.title = (NSUserDefaults.standardUserDefaults().path as NSString).stringByAbbreviatingWithTildeInPath
        view.window?.toolbarHidden = !canForget
    }
}

extension NSView {
    func pin(subview: NSView, inset: CGFloat) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            NSLayoutConstraint(item: subview, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: inset),
            NSLayoutConstraint(item: subview, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: inset),
            NSLayoutConstraint(item: subview, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: inset),
            NSLayoutConstraint(item: subview, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: inset)
        ])
    }
}

extension NSAlert {
    func runModal(completion: ((NSModalResponse) -> Void)? = nil) {
        completion?(runModal())
    }
    
    func beginSheetModalForWindow(window: NSWindow?, completion:  ((NSModalResponse) -> Void)? = nil) {
        guard let window = window else {
            runModal(completion)
            return
        }
        beginSheetModalForWindow(window, completionHandler: completion)
    }
    
    convenience init(message: String?, description: String? = nil, buttons: [String] = []) {
        self.init()
        messageText = message != nil ? message! : ""
        informativeText = description != nil ? description! : ""
        for button in buttons {
            addButtonWithTitle(button)
        }
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
