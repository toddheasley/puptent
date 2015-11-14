//
//  SiteViewController.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa
import PupKit

class SiteViewController: NSViewController {
    var selectedPage: (index: Int, page: Page?) {
        return (-1, nil)
    }
    
    @IBAction func preview(sender: AnyObject?) {
        
    }
    
    @IBAction func makeNewPage(sender: AnyObject?) {
        
    }
    
    @IBAction func deletePage(sender: AnyObject?) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.controlBackgroundColor().CGColor
    }
}
