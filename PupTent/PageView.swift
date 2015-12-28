//
//  PageView.swift
//  PupTent
//
//  (c) 2015 @toddheasley
//

import Cocoa
import PupKit

@objc protocol PageViewDelegate: NSTextViewDelegate {
    func pageViewDidChange(view: PageView)
}

class PageView: NSTextView {
    private var timer: NSTimer?
    
    override var string: String? {
        didSet{
            
        }
    }
    
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textDidChange:", name: NSTextDidChangeNotification, object: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textDidChange:", name: NSTextDidChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: NSTextDidChangeNotification
    func textDidChange(notification: NSNotification) {
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "pageViewDidChange", userInfo: nil, repeats: false)
    }
    
    func pageViewDidChange() {
        guard let delegate = delegate as? PageViewDelegate else {
            return
        }
        delegate.pageViewDidChange(self)
    }
}
