//
//  SiteViewController.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa
import PupKit

class SiteViewController: NSViewController, NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate, PageViewControllerDelegate, ImageViewDelegate {
    @IBOutlet weak var imageView: ImageView?
    @IBOutlet weak var nameTextField: NSTextField?
    @IBOutlet weak var twitterNameTextField: NSTextField?
    @IBOutlet weak var tableView: NSTableView?
    @IBOutlet weak var tableViewPositionConstraint: NSLayoutConstraint?
    @IBOutlet weak var pageView: NSView?
    @IBOutlet weak var pageViewPositionConstraint: NSLayoutConstraint?
    
    let draggedType = "Page"
    var manager: Manager! {
        didSet {
            if let manager = self.manager {
                self.imageView?.image = NSImage(contentsOfFile: manager.path + Manager.bookmarkIconURI)
                self.nameTextField?.stringValue = manager.site.name
                self.twitterNameTextField?.stringValue = manager.site.twitterName.toTwitterFormat()
            }
            self.tableView?.reloadData()
        }
    }
    var pageViewController: PageViewController?
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
            if (self.selectedPage.index > -1) {
                manager.site.pages.removeAtIndex(self.selectedPage.index)
                self.tableView?.reloadData()
                manager.build()
                manager.clean()
            }
            
            self.togglePageViewHidden(true, animated: true)
        }
    }
    
    func dismissSelectedPage() {
        self.togglePageViewHidden(true, animated: true)
    }
    
    private func togglePageViewHidden(hidden: Bool, animated: Bool) {
        self.tableView!.hidden = false
        self.pageView!.hidden = false
        
        var delay: Double = 0.0
        var duration: Double = 0.0
        if (animated) {
            delay = 0.2
            duration = 0.1
        }
        if (hidden) {
            delay.delay {
                duration.animate({
                    self.tableViewPositionConstraint!.animator().constant = 0.0
                    self.pageViewPositionConstraint!.animator().constant = self.view.bounds.size.width - 1.0
                }, {
                    self.pageView!.hidden = true
                    self.tableView!.deselectAll(self)
                })
            }
            return
        }
        delay.delay {
            duration.animate({
                self.tableViewPositionConstraint!.animator().constant = 0.0 - (self.view.bounds.size.width / 3.0)
                self.pageViewPositionConstraint!.animator().constant = 0.0
            }, {
                self.tableView!.hidden = true
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView!.delegate = self
        
        self.tableView!.registerForDraggedTypes([draggedType])
        self.tableView!.setDraggingSourceOperationMask(NSDragOperation.Move, forLocal: true)
        
        self.pageViewController = PageViewController(nibName: "Page", bundle: nil)
        self.pageViewController!.delegate = self
        self.pageView!.addSubview(self.pageViewController!.view)
        self.togglePageViewHidden(true, animated: false)
    }
    
    // MARK: NSTextFieldDelegate
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if let textField = control as? NSTextField, manager = self.manager {
            
            // Trim whitespace
            textField.stringValue = textField.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if (textField == self.nameTextField!) {
                manager.site.name = textField.stringValue
            } else {
                manager.site.twitterName = textField.stringValue.fromTwitterFormat()
                textField.stringValue = textField.stringValue.toTwitterFormat()
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
        if (dropOperation == NSTableViewDropOperation.Above && row < tableView.numberOfRows) {
            
            // Allow cells to be dropped in rows above "new page" cell
            return NSDragOperation.Move
        }
        
        // Prevent cells from being dropped on other cells and below "new page" cell
        return NSDragOperation.None
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        if (row < tableView.numberOfRows) {
            if let manager = self.manager, data: NSData? = info.draggingPasteboard().dataForType(draggedType), indexSet = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? NSIndexSet {
                var index = row
                if (indexSet.firstIndex < index) {
                    index--
                }
                
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
        if let tableView = notification.object as? NSTableView, site = self.manager?.site {
            if (tableView.selectedRow < 0) {
                return
            }
            self.pageViewController!.page = Page()
            if let page = self.selectedPage.page {
                self.pageViewController!.page = page
            }
            self.togglePageViewHidden(false, animated: true)
        }
    }
    
    // MARK: PageViewControllerDelegate
    func handlePageViewControllerChange(pageViewController: PageViewController) {
        
    }
    
    func handlePageViewControllerDelete(pageViewController: PageViewController) {
        self.deleteSelectedPage()
    }
    
    func dismissPageViewController(pageViewController: PageViewController, animated: Bool) {
        self.togglePageViewHidden(true, animated: animated)
    }
    
    // MARK: ImageViewDelegate
    func handleImageViewChange(imageView: ImageView) {
        if let manager = self.manager, bookmarkIconURL = NSURL(fileURLWithPath: manager.path + Manager.bookmarkIconURI) {
            
            // Move existing bookmark icon to trash
            NSFileManager.defaultManager().trashItemAtURL(bookmarkIconURL, resultingItemURL: nil, error: nil)
            if let image = imageView.image, URL = imageView.URL {
                
                // Write new bookmark icon to file
                var error: NSError?
                NSFileManager.defaultManager().copyItemAtURL(URL, toURL: bookmarkIconURL, error: &error)
            }
        }
    }
}

extension Double {
    func delay(delay:() -> Void) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(self * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), delay)
    }
    
    func animate(animate:() -> Void, _ completionHandler:() -> Void) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = self
            animate()
        }, completionHandler: completionHandler)
    }
}

extension String {
    func toTwitterFormat() -> String {
        var string = self.fromTwitterFormat()
        if (count(string) > 0) {
            return "@\(string)"
        }
        return string
    }
    
    func fromTwitterFormat() -> String {
        return self.stringByReplacingOccurrencesOfString("@", withString: "", options: nil, range: nil)
    }
}
