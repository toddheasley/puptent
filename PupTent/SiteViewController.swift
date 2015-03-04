//
//  SiteViewController.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa
import PupKit

class SiteViewController: NSViewController, ImageViewDelegate, NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var imageView: ImageView?
    @IBOutlet weak var nameTextField: NSTextField?
    @IBOutlet weak var twitterNameTextField: NSTextField?
    @IBOutlet weak var tableView: NSTableView?
    
    let draggedType = "Page"
    var manager: Manager! {
        didSet {
            if let manager = self.manager {
                self.imageView?.image = NSImage(contentsOfFile: manager.path + Manager.bookmarkIconURI)
                self.nameTextField?.stringValue = manager.site.name
                self.twitterNameTextField?.stringValue = manager.site.twitterName.twitterNameFormat(true)
            }
            self.tableView?.reloadData()
        }
    }
    
    var selectedPage: (page: Page?, index: Int) {
        get {
            if let site = self.manager?.site {
                if (self.tableView!.selectedRow > -1 && self.tableView!.selectedRow < site.pages.count) {
                    return (site.pages[self.tableView!.selectedRow], self.tableView!.selectedRow)
                }
            }
            return (nil, -1)
        }
    }
    
    func selectNewPage() {
        self.tableView?.selectRowIndexes(NSIndexSet(index: self.tableView!.numberOfRows - 1), byExtendingSelection: false)
    }
    
    func deleteSelectedPage() {
        if let manager = self.manager {
            manager.site.pages.removeAtIndex(self.selectedPage.index)
            self.tableView?.reloadData()
            manager.build()
            manager.clean()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView!.delegate = self
        
        self.tableView!.registerForDraggedTypes([draggedType])
        self.tableView!.setDraggingSourceOperationMask(NSDragOperation.Move, forLocal: true)
    }
    
    // MARK: ImageViewDelegate
    func imageViewDidChange(imageView: ImageView) {
        if let manager = self.manager, URL = NSURL(fileURLWithPath: manager.path + Manager.bookmarkIconURI) {
            
            // Move existing bookmark icon to trash
            NSFileManager.defaultManager().trashItemAtURL(URL, resultingItemURL: nil, error: nil)
            
            if let image = imageView.image {
                
                // Write new bookmark icon to file
            }
        }
    }
    
    // MARK: NSTextFieldDelegate
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if let textField = control as? NSTextField, manager = self.manager {
            
            // Trim whitespace
            textField.stringValue = textField.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if (textField == self.nameTextField!) {
                manager.site.name = textField.stringValue
            } else {
                manager.site.twitterName = textField.stringValue.twitterNameFormat(false)
                textField.stringValue = textField.stringValue.twitterNameFormat(true)
            }
            manager.build()
            manager.clean()
        }
        return true
    }
    
    // MARK: NSTableViewDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
        // Always include row for "new page" cell
        var numberOfRows: Int = 1
        if let site = self.manager?.site {
            
            // Add row for each existing page
            numberOfRows += site.pages.count
        }
        return numberOfRows
    }
    
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        if (rowIndexes.firstIndex < tableView.numberOfRows - 1) {
            
            // Allow existing page cells to be dragged
            var data: NSData = NSKeyedArchiver.archivedDataWithRootObject(rowIndexes)
            pboard.declareTypes([draggedType], owner: self)
            pboard.setData(data, forType: draggedType)
            return true
        }
        
        // Prevent "new page" cell from being dragged
        return false
    }
    
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        if (row < tableView.numberOfRows - 1 || (dropOperation == NSTableViewDropOperation.Above && row < tableView.numberOfRows)) {
            
            // Allow cells to be dropped above "new page" cell
            return NSDragOperation.Move
        }
        
        // Prevent cells from being dropped below "new page" cell
        return NSDragOperation.None
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        if (row < tableView.numberOfRows) {
            var index = row
            if (dropOperation == NSTableViewDropOperation.Above && index > 1) {
                index--
            }
            if let manager = self.manager, data: NSData? = info.draggingPasteboard().dataForType(draggedType), indexSet = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? NSIndexSet {
                
                // Move page to new index in data source
                let page: Page = manager.site.pages[indexSet.firstIndex]
                manager.site.pages.removeAtIndex(indexSet.firstIndex)
                manager.site.pages.insert(page, atIndex: index)
                
                tableView.reloadData()
                manager.build()
                manager.clean()
                
                return true
            }
        }
        return false
    }
    
    // MARK: NSTableViewDelegate
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as? NSTableCellView, let site = self.manager?.site {
            
            // Configure default "new page cell"
            cell.textField!.stringValue = "New Page"
            cell.textField!.textColor = NSColor.grayColor()
            cell.imageView!.image = NSImage(named: "NSStatusNone")
            
            if (row < site.pages.count) {
                
                // Configure cell for existing page
                var page: Page = site.pages[row]
                cell.textField!.stringValue = page.name
                cell.textField!.textColor = NSColor.textColor()
                if (page.index) {
                    cell.imageView!.image = NSImage(named: "NSStatusAvailable")
                } else {
                    cell.imageView!.image = NSImage(named: "NSStatusNone")
                }
            }
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        
    }
}

extension String {
    func twitterNameFormat(on: Bool) -> String {
        var string = self.stringByReplacingOccurrencesOfString("@", withString: "", options: nil, range: nil)
        if (on && count(string) > 0) {
            string = "@\(string)"
        }
        return string
    }
}
