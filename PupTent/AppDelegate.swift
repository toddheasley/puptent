//
//  AppDelegate.swift
//  PupTent
//
//  (c) 2016 @toddheasley
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
    
    @IBAction func preview(_ sender: AnyObject?) {
        mainViewController?.siteViewController?.preview(self)
    }
    
    @IBAction func openInFinder(_ sender: AnyObject?) {
        mainViewController?.openInFinder(sender)
    }
    
    @IBAction func makeNewSite(_ sender: AnyObject?) {
        mainViewController?.makeNewSite(sender)
    }
    
    @IBAction func openExistingSite(_ sender: AnyObject?) {
        mainViewController?.openExistingSite(sender)
    }
    
    @IBAction func forget(_ sender: AnyObject?) {
        mainViewController?.forget(sender)
    }
    
    @IBAction func openSettings(_ sender: AnyObject?) {
        mainViewController?.siteViewController?.openSettings(sender)
    }
    
    @IBAction func makeNewPage(_ sender: AnyObject?) {
        mainViewController?.siteViewController?.makeNewPage(sender)
    }
    
    @IBAction func deletePage(_ sender: AnyObject?) {
        mainViewController?.siteViewController?.deletePage(sender)
    }
    
    @IBAction func close(_ sender: AnyObject?) {
        NSApplication.shared().keyWindow!.performClose(self)
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let mainViewController = mainViewController else {
            return false
        }
        
        switch menuItem {
        case forgetMenuItem:
            return mainViewController.canForget
        case settingsMenuItem, openInFinderMenuItem, newPageMenuItem, previewItem:
            return mainViewController.siteViewController != nil
        case deletePageMenuItem:
            return mainViewController.siteViewController != nil ? mainViewController.siteViewController!.canDeletePage : false
        default:
            return true
        }
    }
    
    // MARK: NSApplicationDelegate
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true;
    }
}
