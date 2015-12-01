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

class PageViewController: NSViewController {
    var delegate: PageViewDelegate?
    private var page: Page = Page()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(page.name)
    }
    
    init?(page: Page?) {
        super.init(nibName: "Page", bundle: nil)
        if let page = page {
            self.page = page
        }
    }
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        return nil
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        return nil
    }
}
