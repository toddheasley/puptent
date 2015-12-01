//
//  AppDelegate.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    weak var mainViewController: MainViewController?
    @IBOutlet weak var forgetMenuItem: NSMenuItem!
    @IBOutlet weak var settingsMenuItem: NSMenuItem!
    @IBOutlet weak var openInFinderMenuItem: NSMenuItem!
    @IBOutlet weak var newPageMenuItem: NSMenuItem!
    @IBOutlet weak var deletePageMenuItem: NSMenuItem!
    @IBOutlet weak var previewItem: NSMenuItem!
    
    @IBAction func preview(sender: AnyObject?) {
        mainViewController?.siteViewController?.preview(self)
    }
    
    @IBAction func openInFinder(sender: AnyObject?) {
        mainViewController?.openInFinder(sender)
    }
    
    @IBAction func makeNewSite(sender: AnyObject?) {
        mainViewController?.makeNewSite(sender)
    }
    
    @IBAction func openExistingSite(sender: AnyObject?) {
        mainViewController?.openExistingSite(sender)
    }
    
    @IBAction func forget(sender: AnyObject?) {
        mainViewController?.forget(sender)
    }
    
    @IBAction func openSettings(sender: AnyObject?) {
        mainViewController?.siteViewController?.openSettings(sender)
    }
    
    @IBAction func makeNewPage(sender: AnyObject?) {
        mainViewController?.siteViewController?.makeNewPage(sender)
    }
    
    @IBAction func deletePage(sender: AnyObject?) {
        mainViewController?.siteViewController?.deletePage(sender)
    }
    
    @IBAction func close(sender: AnyObject?) {
        NSApplication.sharedApplication().keyWindow!.performClose(self)
    }
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        guard let mainViewController = mainViewController else {
            return false
        }
        
        switch menuItem {
        case forgetMenuItem:
            return mainViewController.canForget
        case settingsMenuItem, openInFinderMenuItem, newPageMenuItem, previewItem:
            return mainViewController.siteViewController != nil
        case deletePageMenuItem:
            return mainViewController.siteViewController?.selectedPage.index > -1
        default:
            return true
        }
    }
    
    // MARK: NSApplicationDelegate
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true;
    }
}
