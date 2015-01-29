//
//  AppDelegate.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa
import PupKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var manager: Manager?
    
    @IBOutlet weak var lastSiteMenuItem: NSMenuItem?
    @IBOutlet weak var newPageMenuItem: NSMenuItem?
    @IBOutlet weak var deletePageMenuItem: NSMenuItem?
    
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
            self.openSite(path)
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
            self.openSite(openPanel.URL!.path! + "/")
        })
    }
    
    @IBAction func openLastSite(sender: AnyObject?) {
        self.openSite(Manager.savedPath)
    }
    
    @IBAction func makeNewPage(sender: AnyObject?) {
        
    }
    
    @IBAction func deletePage(sender: AnyObject?) {
        
    }
    
    @IBAction func close(sender: AnyObject?) {
        NSApplication.sharedApplication().keyWindow!.performClose(self)
    }
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        switch (menuItem) {
        case self.lastSiteMenuItem!:
            return !Manager.savedPath.isEmpty
        case self.newPageMenuItem!:
            return false
        case self.deletePageMenuItem!:
            return false
        default:
            return true
        }
    }
    
    private func openSite(path: String) {
        var error: NSError?
        self.manager = Manager(path: path, error: &error, savePath: true)
        if (error == nil) {
            
            return
        }
        self.showAlert("\(error!.localizedDescription)")
    }
    
    private func showAlert(text: String) {
        var alert: NSAlert = NSAlert()
        alert.addButtonWithTitle("OK")
        alert.messageText = text
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().keyWindow!, completionHandler: { (response) -> Void in
            
        })
    }
    
    // NSApplicationDelegate
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true;
    }
}

extension Manager {
    class var savedPath: String {
        get {
            if let path = NSUserDefaults.standardUserDefaults().objectForKey("path") as? String {
                if (Manager.exists(path)) {
                    return path
                }
            }
            Manager.savedPath = ""
            return ""
        }
        set (path) {
            NSUserDefaults.standardUserDefaults().setObject(path as NSString, forKey: "path")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    convenience init?(path: String, error: NSErrorPointer, savePath: Bool) {
        self.init(path: path, error: error)
        if (savePath) {
            Manager.savedPath = path
        }
    }
}
