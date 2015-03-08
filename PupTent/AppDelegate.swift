//
//  AppDelegate.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var mainViewController: MainViewController?
    @IBOutlet weak var forgetMenuItem: NSMenuItem?
    @IBOutlet weak var newPageMenuItem: NSMenuItem?
    @IBOutlet weak var deletePageMenuItem: NSMenuItem?
    @IBOutlet weak var dismissPageMenuItem: NSMenuItem?
    @IBOutlet weak var previewItem: NSMenuItem?
    
    @IBAction func preview(sender: AnyObject?) {
        self.mainViewController?.preview(self)
    }
    
    @IBAction func makeNewSite(sender: AnyObject?) {
        self.mainViewController?.makeNewSite(sender)
    }
    
    @IBAction func openExistingSite(sender: AnyObject?) {
        self.mainViewController?.openExistingSite(sender)
    }
    
    @IBAction func forget(sender: AnyObject?) {
        self.mainViewController?.forget(sender)
    }
    
    @IBAction func makeNewPage(sender: AnyObject?) {
        self.mainViewController?.makeNewPage(sender)
    }
    
    @IBAction func deletePage(sender: AnyObject?) {
        self.mainViewController?.deletePage(sender)
    }
    
    @IBAction func dismissPage(sender: AnyObject?) {
        self.mainViewController?.dismissPage(sender)
    }
    
    @IBAction func close(sender: AnyObject?) {
        NSApplication.sharedApplication().keyWindow!.performClose(self)
    }
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        if let mainViewController = self.mainViewController {
            switch (menuItem) {
            case self.forgetMenuItem!:
                return mainViewController.canForget
            case self.newPageMenuItem!:
                fallthrough
            case self.previewItem!:
                return mainViewController.siteViewController?.manager != nil
            case self.deletePageMenuItem!:
                return mainViewController.canDeletePage
            case self.dismissPageMenuItem!:
                return mainViewController.canDismissPage
            default:
                return true
            }
        }
        return false
    }
    
    // MARK: NSApplicationDelegate
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true;
    }
}
