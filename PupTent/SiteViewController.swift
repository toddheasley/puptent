//
//  SiteViewController.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa
import PupKit

class SiteViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, PageCellViewDelegate {
    private let draggedType: String = "Page"
    private var timer: NSTimer?
    var manager: Manager!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var textView: NSTextView!
    
    var selectedPage: (index: Int, page: Page?) {
        if (tableView.selectedRow > -1 && tableView.selectedRow < manager.site.pages.count) {
            return ( tableView.selectedRow, manager.site.pages[tableView.selectedRow])
        }
        return (-1, nil)
    }
    
    @IBAction func openSettings(sender: AnyObject?) {
        tableView.deselectAll(self)
        (self.view.window as? Window)?.settingsButton.state = 1
    }
    
    @IBAction func preview(sender: AnyObject?) {
        guard let page = self.selectedPage.page else {
            NSWorkspace.sharedWorkspace().openFile(manager.path + manager.site.URI)
            return
        }
        NSWorkspace.sharedWorkspace().openFile(manager.path + page.URI)
    }
    
    @IBAction func makeNewPage(sender: AnyObject?) {
        tableView.selectRowIndexes(NSIndexSet(index: tableView.numberOfRows - 1), byExtendingSelection: false)
    }
    
    @IBAction func deletePage(sender: AnyObject?) {
        if (tableView.selectedRow < 0 || tableView.selectedRow >= manager.site.pages.count) {
            return
        }
        
        do {
            manager.site.pages.removeAtIndex(tableView.selectedRow)
            try manager.build()
            tableView.removeRowsAtIndexes(NSIndexSet(index: tableView.selectedRow), withAnimation: .EffectNone)
        } catch {
            print(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.controlBackgroundColor().CGColor
        
        tableView.registerForDraggedTypes([draggedType])
        tableView.setDraggingSourceOperationMask(NSDragOperation.Move, forLocal: true)
        
        textView.textContainerInset = NSMakeSize(11.0, 13.0)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textViewDidChange:", name: NSTextDidChangeNotification, object: nil)
        if (selectedPage.index < 0) {
            openSettings(self)
        }
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    init?(manager: Manager) {
        super.init(nibName: "Site", bundle: nil)
        self.manager = manager
    }
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        return nil
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        return nil
    }
    
    // MARK: NSTableViewDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return manager.site.pages.count + 1 // Add "new page" cell to existing pages
    }
    
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pasteboard: NSPasteboard) -> Bool {
        if (rowIndexes.firstIndex > tableView.numberOfRows - 2) {
            
            // Prevent "new page" cell drag
            return false
        }
        
        // Allow existing page cells drag
        pasteboard.declareTypes([draggedType], owner: self)
        pasteboard.setData(NSKeyedArchiver.archivedDataWithRootObject(rowIndexes), forType: draggedType)
        return true
    }
    
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        if (dropOperation == NSTableViewDropOperation.Above && row < tableView.numberOfRows) {
            
            // Allow cell drop in rows above "new page" cell
            return NSDragOperation.Move
        }
        
        // Prevent cells drop onto other cells and below "new page" cell
        return NSDragOperation.None
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        guard let data = info.draggingPasteboard().dataForType(draggedType), indexSet = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSIndexSet where row < tableView.numberOfRows else {
            return false
        }
        
        var selectedPage: Page?
        if (tableView.selectedRow > -1 && tableView.selectedRow < manager.site.pages.count) {
            
            // Remember current page selection
            selectedPage = manager.site.pages[tableView.selectedRow]
        }
        
        var index = row
        if (indexSet.firstIndex < index) {
            index--
        }
        
        // Move page to new index in data source
        let page: Page = manager.site.pages[indexSet.firstIndex]
        manager.site.pages.removeAtIndex(indexSet.firstIndex)
        manager.site.pages.insert(page, atIndex: index)
        do {
            try manager.build()
            try manager.clean()
        } catch {
            print(error)
        }
        
        tableView.reloadData()
        if let selectedPage = selectedPage {
            
            // Restore page selection
            tableView.selectRowIndexes(NSIndexSet(index: (manager.site.pages as NSArray).indexOfObject(selectedPage)), byExtendingSelection: false)
        } else {
            openSettings(self)
        }
        return true
    }
    
    // MARK: NSTableViewDelegate
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let view = tableView.makeViewWithIdentifier("PageCellView", owner: self) as? PageCellView else {
            return nil
        }
        
        // Configure as blank "new page" cell
        view.delegate = self
        view.textField!.stringValue = ""
        view.secondaryTextField!.stringValue = ""
        view.button.enabled = false
        view.button.state = 0
        if (row < manager.site.pages.count) {
            
            // Configure cell for existing page
            let page = manager.site.pages[row]
            view.textField!.stringValue = "\(page.name)"
            view.secondaryTextField!.stringValue = "\(page.URI)"
            view.button.enabled = true
            view.button.state = page.index ? 1 : 0
        }
        return view
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return PageRowView(index: row)
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        textView.string = ""
        guard let tableView = notification.object as? NSTableView where tableView.selectedRow > -1 else {
            openSettings(self)
            return
        }
        
        var page: Page = Page()
        if (tableView.selectedRow < manager.site.pages.count) {
            page = manager.site.pages[tableView.selectedRow]
        } else if let view = tableView.viewAtColumn(0, row: tableView.selectedRow, makeIfNecessary: false) as? PageCellView {
            manager.site.pages.append(page)
            view.textField?.becomeFirstResponder()
            view.button.enabled = true
        }
        textView.string = page.body
        (self.view.window as? Window)?.settingsButton.state = 0
    }
    
    // MARK: PageCellViewDelegate
    func pageCellViewDidChange(view: PageCellView) {
        if (tableView.selectedRow < 0) {
            return
        }
        let page = manager.site.pages[tableView.selectedRow]
        if (view.textField!.stringValue.isEmpty) {
            if (page.name.isEmpty) {
                manager.site.pages.removeAtIndex(tableView.selectedRow)
            }
            tableView.deselectAll(self)
            tableView.reloadData()
            return
        }
        page.name = view.textField!.stringValue
        page.URI = view.secondaryTextField.stringValue
        page.index = view.button.state == 1
        do {
            try manager.build()
            try manager.clean()
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    // MARK: NSTextDidChangeNotification
    func textViewDidChange(notification: NSNotification) {
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "captureTextView", userInfo: nil, repeats: false)
    }
    
    func captureTextView() {
        if (tableView.selectedRow < 0) {
            return
        }
        let page = manager.site.pages[tableView.selectedRow]
        page.body = textView.string!
        do {
            try manager.build()
            try manager.clean()
        } catch {
            print(error)
        }
    }
}
