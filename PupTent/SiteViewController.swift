//
//  SiteViewController.swift
//  PupTent
//
//  (c) 2016 @toddheasley
//

import Cocoa
import PupKit

class SiteViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, PageCellViewDelegate, PageViewDelegate, SettingsViewDelegate {
    private let draggedType: String = "Page"
    var manager: Manager!
    @IBOutlet var splitView: NSSplitView!
    @IBOutlet var pagesTableView: NSTableView!
    @IBOutlet var pageView: PageView!
    @IBOutlet var settingsView: SettingsView!
    
    var selectedPage: (index: Int, page: Page?) {
        if pagesTableView.selectedRow > -1 && pagesTableView.selectedRow < manager.site.pages.count {
            return (pagesTableView.selectedRow, manager.site.pages[pagesTableView.selectedRow])
        }
        return (-1, nil)
    }
    
    var canDeletePage: Bool {
        let index = selectedPage.index
        return index > -1 && index < pagesTableView.numberOfRows - 1
    }
    
    @IBAction func openSettings(_ sender: AnyObject?) {
        pagesTableView.deselectAll(self)
        (self.view.window as? Window)?.settingsButton.state = 1
        settingsView.nameText = manager.site.name
        settingsView.URLText = manager.site.URL
        settingsView.twitterText = manager.site.twitter
        settingsView.bookmarkIconPath = "\(manager.path)\(HTML.bookmarkIconURI)"
        settingsView.stylesheetPath = "\(manager.path)\(HTML.stylesheetURI)"
        settingsView.isHidden = false
    }
    
    @IBAction func preview(_ sender: AnyObject?) {
        guard let page = self.selectedPage.page else {
            NSWorkspace.shared().openFile(manager.path + manager.site.URI)
            return
        }
        NSWorkspace.shared().openFile(manager.path + page.URI)
    }
    
    @IBAction func makeNewPage(_ sender: AnyObject?) {
        pagesTableView.selectRowIndexes(IndexSet(integer: pagesTableView.numberOfRows - 1), byExtendingSelection: false)
    }
    
    @IBAction func deletePage(_ sender: AnyObject?) {
        if pagesTableView.selectedRow < 0 || pagesTableView.selectedRow >= manager.site.pages.count {
            return
        }
        do {
            manager.site.pages.remove(at: pagesTableView.selectedRow)
            try manager.build()
            try manager.clean()
            pagesTableView.removeRows(at: IndexSet(integer: pagesTableView.selectedRow), withAnimation: NSTableViewAnimationOptions())
        } catch let error as NSError {
            NSAlert(message: error.localizedFailureReason, description: error.localizedDescription, buttons: [
                "Cancel"
            ]).beginSheetModal(for: view.window!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        
        pagesTableView.register(forDraggedTypes: [draggedType])
        pagesTableView.setDraggingSourceOperationMask(NSDragOperation.move, forLocal: true)
        
        settingsView.delegate = self
        splitView.subviews[1].addSubview(settingsView)
        splitView.subviews[1].pin(settingsView, inset: 0.0)
        
        pageView.textContainerInset = NSMakeSize(11.0, 13.0)
        pageView.path = manager.path
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if selectedPage.index < 0 {
            openSettings(self)
        }
    }
    
    init?(manager: Manager) {
        super.init(nibName: "Site", bundle: nil)
        self.manager = manager
    }
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        return nil
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        return nil
    }
    
    // MARK: NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return manager.site.pages.count + 1 // Add "new page" cell to existing pages
    }
    
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pasteboard: NSPasteboard) -> Bool {
        if rowIndexes.first! > tableView.numberOfRows - 2 {
            
            // Prevent "new page" cell drag
            return false
        }
        
        // Allow existing page cells drag
        pasteboard.declareTypes([draggedType], owner: self)
        pasteboard.setData(NSKeyedArchiver.archivedData(withRootObject: rowIndexes), forType: draggedType)
        return true
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        if dropOperation == NSTableViewDropOperation.above && row < tableView.numberOfRows {
            
            // Allow cell drop in rows above "new page" cell
            return NSDragOperation.move
        }
        
        // Prevent cells drop onto other cells and below "new page" cell
        return NSDragOperation()
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        guard let data = info.draggingPasteboard().data(forType: draggedType), let indexSet = NSKeyedUnarchiver.unarchiveObject(with: data) as? IndexSet, row < tableView.numberOfRows else {
            return false
        }
        let selectedPage = self.selectedPage.page // Remember current page selection
        
        var index = row
        if indexSet.first! < index {
            index -= 1
        }
        
        // Move page to new index in data source
        let page: Page = manager.site.pages[indexSet.first!]
        manager.site.pages.remove(at: indexSet.first!)
        manager.site.pages.insert(page, at: index)
        do {
            try manager.build()
            try manager.clean()
        } catch let error as NSError {
            NSAlert(message: error.localizedFailureReason, description: error.localizedDescription, buttons: [
                "Cancel"
            ]).beginSheetModal(for: view.window!)
        }
        
        tableView.reloadData()
        if let selectedPage = selectedPage {
            
            // Restore page selection
            tableView.selectRowIndexes(IndexSet(integer: (manager.site.pages as NSArray).index(of: selectedPage)), byExtendingSelection: false)
        } else {
            openSettings(self)
        }
        return true
    }
    
    // MARK: NSTableViewDelegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let view = tableView.make(withIdentifier: "PageCellView", owner: self) as? PageCellView else {
            return nil
        }
        
        // Configure as blank "new page" cell
        view.delegate = self
        view.textField!.stringValue = ""
        view.secondaryTextField!.stringValue = ""
        view.button.isEnabled = false
        view.button.state = 0
        if row < manager.site.pages.count {
            
            // Configure cell for existing page
            let page = manager.site.pages[row]
            view.textField!.stringValue = "\(page.name)"
            view.secondaryTextField!.stringValue = "\(page.URI)"
            view.button.isEnabled = true
            view.button.state = page.index ? 1 : 0
        }
        return view
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return PageRowView(index: row)
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        pageView.string = ""
        guard let tableView = notification.object as? NSTableView, tableView.selectedRow > -1 else {
            openSettings(self)
            return
        }
        
        var page: Page = Page()
        if tableView.selectedRow < manager.site.pages.count {
            page = manager.site.pages[tableView.selectedRow]
        } else if let view = tableView.view(atColumn: 0, row: tableView.selectedRow, makeIfNecessary: false) as? PageCellView {
            manager.site.pages.append(page)
            view.textField?.becomeFirstResponder()
            view.button.isEnabled = true
        }
        pageView.string = page.body
        (self.view.window as? Window)?.settingsButton.state = 0
        settingsView.isHidden = true
    }
    
    // MARK: PageCellViewDelegate
    func pageCellViewDidChange(_ view: PageCellView) {
        let row = pagesTableView.row(for: view)
        if row < 0 {
            return
        }
        let page = manager.site.pages[row]
        if view.textField!.stringValue.isEmpty {
            if page.name.isEmpty {
                manager.site.pages.remove(at: pagesTableView.selectedRow)
            }
            pagesTableView.deselectAll(self)
            pagesTableView.reloadData()
            return
        }
        page.name = view.textField!.stringValue
        page.URI = view.secondaryTextField.stringValue
        page.index = view.button.state == 1
        do {
            try manager.build()
            try manager.clean()
        } catch let error as NSError {
            NSAlert(message: error.localizedFailureReason, description: error.localizedDescription, buttons: [
                "Cancel"
            ]).beginSheetModal(for: view.window!)
        }
        if pagesTableView.numberOfRows == manager.site.pages.count {
            pagesTableView.insertRows(at: IndexSet(integer: manager.site.pages.count), withAnimation: NSTableViewAnimationOptions())
        }
    }
    
    // MARK: PageViewDelegate
    func pageViewDidChange(_ view: PageView) {
        guard let string = view.string, let page = selectedPage.page else {
            return
        }
        page.body = string
        do {
            try manager.build()
            try manager.clean()
        } catch let error as NSError {
            NSAlert(message: error.localizedFailureReason, description: error.localizedDescription, buttons: [
                "Cancel"
            ]).beginSheetModal(for: view.window!)
        }
    }
    
    // MARK: SettingsViewDelegate
    func settingsViewDidChange(_ view: SettingsView) {
        manager.site.name = view.nameText
        manager.site.URL = view.URLText
        manager.site.twitter = view.twitterText
        do {
            try manager.build()
            try manager.clean()
        } catch let error as NSError {
            NSAlert(message: error.localizedFailureReason, description: error.localizedDescription, buttons: [
                "Cancel"
            ]).beginSheetModal(for: view.window!)
        }
    }
}
