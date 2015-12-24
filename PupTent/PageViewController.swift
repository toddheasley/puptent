//
//  PageViewController.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa
import PupKit

protocol PageViewDelegate {
    func pageDidChange(page: Page)
    func pageDidDelete(page: Page)
}

class PageViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    var delegate: PageViewDelegate?
    private let draggedType = "PageSection"
    private var page: Page = Page()
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerForDraggedTypes([
            draggedType,
            kUTTypeFileURL as String
        ])
        tableView.setDraggingSourceOperationMask(NSDragOperation.Move, forLocal: true)
        tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.None
    }
    
    convenience init?(page: Page?) {
        self.init(nibName: "Page", bundle: nil)
        if let page = page {
            self.page = page
        }
    }
    
    // MARK: NSTableViewDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return page.sections.count + 2 // Include page info and "new section" cells
    }
    
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pasteboard: NSPasteboard) -> Bool {
        if (rowIndexes.firstIndex < 1 || rowIndexes.firstIndex > tableView.numberOfRows - 2) {
            
            // Prevent page info and "new section" cell drag
            return false
        }
        
        // Allow existing page cells drag
        pasteboard.declareTypes([draggedType], owner: self)
        pasteboard.setData(NSKeyedArchiver.archivedDataWithRootObject(rowIndexes), forType: draggedType)
        return true
    }
    
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        if (dropOperation == NSTableViewDropOperation.Above && row > 0 && row < tableView.numberOfRows) {
            if let _ = info.draggingSource() as? NSTableView {
                
                // Move local cells
                return NSDragOperation.Move
            }
            if (NSImage.canInitWithPasteboard(info.draggingPasteboard())) {
                
                // Copy non-local image files
                return NSDragOperation.Copy
            }
        }
        
        // Prevent cells drop onto other cells, above info cell and below "new page" cell
        return NSDragOperation.None
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        guard let data = info.draggingPasteboard().dataForType(draggedType), indexSet = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSIndexSet where row < tableView.numberOfRows else {
            return false
        }
        
        return false
    }
    
    // MARK: NSTableViewDelegate
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        switch row {
        case 0:
            return 100.0
        default:
            /*
            if let cell = tableView.makeViewWithIdentifier(tableView.tableColumns[0].identifier!, owner: self) as? PageSectionCellView, let page = self.page {
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
                return cell.frame.size.height
            }
            return 0.0
            */
            return 200.0
        }
    }
}
