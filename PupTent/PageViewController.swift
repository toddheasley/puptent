//
//  PageViewController.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa
import PupKit

class PageViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, PageCellViewDelegate {
    let draggedType = "PageSection"
    var delegate: PageViewControllerDelegate?
    var path: String?
    var page: Page? {
        didSet {
            
            self.pageCellView!.deleteButton!.hidden = true
            if let page = self.page {
                self.pageCellView!.deleteButton!.hidden = page.URI.isEmpty
            }
            self.tableView!.scrollToBeginningOfDocument(self)
            self.tableView!.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        self.view.layer!.backgroundColor = NSColor(calibratedWhite: 0.9, alpha: 1.0).CGColor
        
        self.tableView!.registerForDraggedTypes([draggedType, kUTTypeFileURL])
        self.tableView!.setDraggingSourceOperationMask(NSDragOperation.Move, forLocal: true)
        self.tableView!.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.None
        self.tableView!.postsBoundsChangedNotifications = true
        
        // Subscribe to table view scroll notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleBoundsChange:", name: NSViewBoundsDidChangeNotification, object: nil)
    }
    
    func handleBoundsChange(notification: NSNotification) {
        if let clipView = notification.object as? NSClipView {
            
        }
    }
    
    // MARK: NSTableViewDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if let page = self.page {
            return page.sections.count + 2
        }
        return 0
    }
    
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        if (rowIndexes.firstIndex > 0 && rowIndexes.firstIndex < tableView.numberOfRows - 1) {
            
            // Allow existing page cells to be dragged
            var data: NSData = NSKeyedArchiver.archivedDataWithRootObject(rowIndexes)
            pboard.declareTypes([draggedType], owner: self)
            pboard.setData(data, forType: draggedType)
            return true
        }
        
        // Prevent first cell and "new section" cell from being dragged
        return false
    }
    
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        if (dropOperation == NSTableViewDropOperation.Above && row > 0 && row < tableView.numberOfRows) {
            
            // Allow drop in rows below first cell and above "new section" cell
            if let draggingSource = info.draggingSource() as? NSTableView {
                
                // Move local cells
                return NSDragOperation.Move
            }
            if (NSImage.canInitWithPasteboard(info.draggingPasteboard())) {
                
                // Copy non-local image files
                return NSDragOperation.Copy
            }
        }
        
        // Prevent cells from being dropped on other cells and below "new section" cell
        return NSDragOperation.None
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        if (row > 0 && row < tableView.numberOfRows) {
            if let page = self.page {
                if let  data: NSData = info.draggingPasteboard().dataForType(draggedType), indexSet = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSIndexSet {
                    
                    // Calculate row for cell move
                    var index = row - 1
                    if (indexSet.firstIndex < index) {
                        index--
                    }
                    
                    // Move page section to new index in data source
                    let section: PageSection = page.sections[indexSet.firstIndex - 1]
                    page.sections.removeAtIndex(indexSet.firstIndex - 1)
                    page.sections.insert(section, atIndex: index)
                    tableView.reloadData()
                    
                    // Notify delegate
                    self.delegate?.handlePageViewControllerChange(self)
                    return true
                }
                if (NSImage.canInitWithPasteboard(info.draggingPasteboard())) {
                    
                    // Copy page section image and add page section
                    if let path = self.path, pasteboardURL = NSURL(fromPasteboard: info.draggingPasteboard()) {
                        if let URL = NSURL(fileURLWithPath: path + Manager.mediaPath + "/" + pasteboardURL.lastPathComponent!) {
                            
                            // Move existing media file to trash
                            NSFileManager.defaultManager().trashItemAtURL(URL, resultingItemURL: nil, error: nil)
                            
                            // Copy new image file
                            var error: NSError?
                            NSFileManager.defaultManager().copyItemAtURL(pasteboardURL, toURL: URL, error: &error)
                            if let error = error {
                                
                                // Copy failed
                                return false
                            }
                            
                            // Add page section for copied image file
                            var section: PageSection = PageSection()
                            section.type = .Image
                            section.URI = Manager.mediaPath + "/" + URL.lastPathComponent!
                            page.sections.insert(section, atIndex: row - 1)
                            tableView.reloadData()
                            if (!page.URI.isEmpty) {
                                
                                // Notify delegate
                                self.delegate?.handlePageViewControllerChange(self)
                            }
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    // MARK: NSTableViewDelegate
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        switch row {
        case 0:
            return self.pageCellView!.frame.size.height
        default:
            if let cell = tableView.makeViewWithIdentifier(tableView.tableColumns[0].identifier!, owner: self) as? PageSectionCellView, let page = self.page {
                cell.content = ""
                if (row <= page.sections.count) {
                    let section = page.sections[row - 1]
                    switch section.type {
                    case .Image:
                        if let path = self.path, URL = NSURL(fileURLWithPath: path + section.URI), image = NSImage(contentsOfURL: URL) {
                            cell.content = image
                        } else {
                            cell.content = NSImage(named: "MissingImage")
                        }
                    case .Audio, .Video:
                        cell.content = section.URI
                    case .Basic:
                        cell.content = section.text
                    }
                }
                return cell.frame.size.height
            }
            return 0.0
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch row {
        case 0:
            if let cell = self.pageCellView, let page = self.page {
                
                // Configure name/URI cell
                cell.delegate = self
                cell.textField!.textColor = NSColor.textColor()
                cell.textField!.stringValue = page.name
                cell.URITextField!.textColor = NSColor.lightGrayColor()
                cell.URITextField!.stringValue = page.URI
                cell.index = page.index
                return cell
            }
        default:
            if let cell = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as? PageSectionCellView, let page = self.page {
                
                // Configure default "new page section cell"
                cell.delegate = self
                cell.content = ""
                if (row <= page.sections.count) {
                    let section = page.sections[row - 1]
                    switch section.type {
                    case .Image:
                        if let path = self.path, URL = NSURL(fileURLWithPath: path + section.URI), image = NSImage(contentsOfURL: URL) {
                            cell.content = image
                        } else {
                            cell.content = NSImage(named: "NSStopProgressTemplate")
                        }
                    case .Audio, .Video:
                        cell.content = section.URI
                    case .Basic:
                        cell.content = section.text
                    }
                }
                return cell
            }
        }
        return nil
    }
    
    // MARK: PageCellViewDelegate
    func handlePageCellViewChange(pageCellView: NSTableCellView) {
        if let page = self.page {
            var row = self.tableView!.rowForView(pageCellView)
            if (row > 0) {
                
                // Page section changed
                row--
                if let cell = pageCellView as? PageSectionCellView {
                    var section = PageSection()
                    section.type = .Basic
                    section.text = cell.textField!.stringValue
                    if (row < page.sections.count) {
                        
                        // Update existing page section
                        page.sections[row] = section
                    } else {
                        
                        // Add new page section
                        page.sections.append(section)
                    }
                    
                    // Prompt table view to recalculate row height
                    if (!cell.editing) {
                        self.tableView!.reloadData()
                    }
                    self.tableView!.noteHeightOfRowsWithIndexesChanged(NSIndexSet(index: self.tableView!.rowForView(pageCellView)))
                }
            } else {
                
                // Name/URI cell changed
                if (self.pageCellView!.URITextField!.stringValue.isEmpty) {
                    return
                }
                page.name = self.pageCellView!.textField!.stringValue
                page.URI = self.pageCellView!.URITextField!.stringValue
                page.index = self.pageCellView!.index
                
                // Update
                if (!page.URI.isEmpty) {
                    self.pageCellView!.deleteButton!.hidden = false
                }
            }
            
            // Notify delegate
            self.delegate?.handlePageViewControllerChange(self)
        }
    }
    
    func handlePageCellViewDelete(pageCellView: NSTableCellView) {
        if let page = self.page {
            let row = self.tableView!.rowForView(pageCellView) - 1
            if (row > -1 && row < page.sections.count) {
                
                // Delete page section
                page.sections.removeAtIndex(row)
                
                // Notify delegate
                self.delegate?.handlePageViewControllerChange(self)
                
                self.tableView!.reloadData()
                return
            }
            
            // Delete entire page
            var alert = NSAlert()
            alert.messageText = ""
            alert.informativeText = "Delete this page?"
            alert.addButtonWithTitle("Delete")
            alert.addButtonWithTitle("Cancel")
            alert.beginSheetModalForWindow(self.view.window!, completionHandler: { response in
                if (response != NSAlertFirstButtonReturn) {
                    return
                }
                
                // Notify delegate
                self.delegate?.handlePageViewControllerDelete(self)
            })
        }
    }
    
    // MARK: IBOutlet, IBAction
    @IBOutlet weak var tableView: NSTableView?
    @IBOutlet weak var pageCellView: PageDetailsCellView?
    @IBOutlet weak var dismissButton: NSButton?
    
    @IBAction func dismiss(sender: AnyObject?) {
        
        // Notify delegate
        self.delegate?.dismissPageViewController(self, animated: true)
    }
}

protocol PageViewControllerDelegate {
    func dismissPageViewController(pageViewController: PageViewController, animated: Bool)
    func handlePageViewControllerChange(pageViewController: PageViewController)
    func handlePageViewControllerDelete(pageViewController: PageViewController)
}
