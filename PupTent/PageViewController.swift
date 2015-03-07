//
//  PageViewController.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa
import PupKit

class PageViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView?
    @IBOutlet weak var dismissButton: NSButton?
    
    let draggedType = "Page"
    var delegate: PageViewControllerDelegate?
    var page: Page? {
        didSet {
            println("\(self.page)")
        }
    }
    
    @IBAction func dismiss(sender: AnyObject?) {
        
        // Notify delegate
        self.delegate?.dismissPageViewController(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tableView!.registerForDraggedTypes([draggedType])
        self.tableView!.setDraggingSourceOperationMask(NSDragOperation.Move, forLocal: true)
    }
    
    // MARK: NSTableViewDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return 0
    }
    
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        return false
    }
    
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        return NSDragOperation.None
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
    
        return false
    }
    
    // MARK: NSTableViewDelegate
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return nil
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        
    }

}

protocol PageViewControllerDelegate {
    func handlePageViewControllerChange(pageViewController: PageViewController)
    func dismissPageViewController(pageViewController: PageViewController)
}
