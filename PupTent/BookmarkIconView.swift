import Cocoa

class BookmarkIconView: NSImageView {
    private var button: NSButton = NSButton()
    
    override var image: NSImage? {
        didSet{
            button.isHidden = image != nil
        }
    }
    
    @objc func chooseImage(_ sender: AnyObject) {
        let openPanel: NSOpenPanel = NSOpenPanel()
        openPanel.allowedFileTypes = NSImage.imageTypes
        openPanel.title = "Choose a Bookmark Icon..."
        openPanel.prompt = "Use This Image"
        openPanel.begin{ result in
            if let url: URL = openPanel.url, let image: NSImage = NSImage(contentsOf: url), result == NSApplication.ModalResponse.OK {
                self.image = image
                self.sendAction(self.action, to: self.target)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        button.alphaValue = 0.0
        button.target = self
        button.action = #selector(BookmarkIconView.chooseImage(_:))
        addSubview(button)
        pin(button, inset: 0.0)
    }
}
