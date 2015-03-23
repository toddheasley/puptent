//
//  AppDelegate.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        if let mainViewController = self.mainViewController {
            switch menuItem {
            case self.forgetMenuItem!:
                return mainViewController.canForget
            case self.newPageMenuItem!, self.previewItem!:
                return mainViewController.siteViewController?.manager != nil
            case self.deletePageMenuItem!:
                return mainViewController.siteViewController?.selectedPage.index > -1
            case self.dismissPageMenuItem!:
                return mainViewController.siteViewController?.tableView?.selectedRow > -1
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
    
    // MARK: IBOutlet, IBAction
    @IBOutlet weak var mainViewController: MainViewController?
    @IBOutlet weak var forgetMenuItem: NSMenuItem?
    @IBOutlet weak var newPageMenuItem: NSMenuItem?
    @IBOutlet weak var deletePageMenuItem: NSMenuItem?
    @IBOutlet weak var dismissPageMenuItem: NSMenuItem?
    @IBOutlet weak var previewItem: NSMenuItem?
    
    @IBAction func preview(sender: AnyObject?) {
        self.mainViewController?.siteViewController?.preview(self)
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
        self.mainViewController?.siteViewController?.selectNewPage()
    }
    
    @IBAction func deletePage(sender: AnyObject?) {
        self.mainViewController?.siteViewController?.deleteSelectedPage()
    }
    
    @IBAction func dismissPage(sender: AnyObject?) {
        self.mainViewController?.siteViewController?.dismissSelectedPage()
    }
    
    @IBAction func close(sender: AnyObject?) {
        NSApplication.sharedApplication().keyWindow!.performClose(self)
    }
}
