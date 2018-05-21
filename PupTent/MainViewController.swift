import Cocoa
import PupKit

class MainViewController: NSViewController {
    var siteViewController: SiteViewController?
    @IBOutlet var emptyView: NSView!
    @IBOutlet var makeNewSiteButton: NSButton!
    @IBOutlet var openExistingSiteButton: NSButton!
    
    var canForget: Bool {
        return !UserDefaults.standard.path.isEmpty
    }
    
    private func openSite(_ path: String, animated: Bool) {
        do {
            let manager: Manager = try Manager(path: path)
            
            guard let siteViewController: SiteViewController = SiteViewController(manager: manager) else {
                return
            }
            self.siteViewController = siteViewController
            view.addSubview(siteViewController.view)
            view.pin(siteViewController.view, inset: 0.0)
            (view.window as? Window)?.pathLabel.title = (manager.path as NSString).abbreviatingWithTildeInPath
            view.window?.toolbarHidden = false
            
            // Remember path
            UserDefaults.standard.path = manager.path
        } catch {
            forget(self)
            NSAlert(message: (error as NSError).localizedFailureReason, description: error.localizedDescription, buttons: [
                "Cancel",
                "Open in Finder"
            ]).runModal{ response in
                if response == .alertSecondButtonReturn {
                    NSWorkspace.shared.open(URL(fileURLWithPath: path))
                }
            }
        }
    }
    
    @IBAction func forget(_ sender: AnyObject?) {
        view.window?.toolbarHidden = true
        siteViewController?.view.removeFromSuperview()
        siteViewController = nil
        
        // Forget path
        UserDefaults.standard.path = ""
    }
    
    @IBAction func makeNewSite(_ sender: AnyObject?) {
        let openPanel: NSOpenPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.title = "Choose an Empty Folder..."
        openPanel.prompt = "Use This Folder"
        openPanel.begin{ result in
            guard result == .OK else {
                return
            }
            let path: String = openPanel.url!.path + "/"
            do {
                try Manager.pitch(path: path)
                self.openSite(path, animated: true)
            } catch {
                NSAlert(message: (error as NSError).localizedFailureReason, description: error.localizedDescription, buttons: [
                    "Cancel",
                    "Open in Finder"
                ]).runModal{ response in
                    if response == .alertSecondButtonReturn {
                        NSWorkspace.shared.open(URL(fileURLWithPath: path))
                    }
                }
            }
        }
    }
    
    @IBAction func openExistingSite(_ sender: AnyObject?) {
        let openPanel: NSOpenPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.title = "Choose an Existing Site..."
        openPanel.begin{ result in
            guard result == .OK else {
                return
            }
            self.openSite(openPanel.url!.path + "/", animated: true)
        }
    }
    
    @IBAction func openInFinder(_ sender: AnyObject?) {
        NSWorkspace.shared.open(URL(fileURLWithPath: UserDefaults.standard.path))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (NSApplication.shared.delegate as? AppDelegate)?.mainViewController = self
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        
        if canForget {
            openSite(UserDefaults.standard.path, animated: false) // Open most recent site
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        (view.window as? Window)?.pathLabel.title = (UserDefaults.standard.path as NSString).abbreviatingWithTildeInPath
        view.window?.toolbarHidden = !canForget
    }
}

extension NSView {
    func pin(_ subview: NSView, inset: CGFloat) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            NSLayoutConstraint(item: subview, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: inset),
            NSLayoutConstraint(item: subview, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: inset),
            NSLayoutConstraint(item: subview, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: inset),
            NSLayoutConstraint(item: subview, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: inset)
        ])
    }
}

extension NSAlert {
    func runModal(_ completion: ((NSApplication.ModalResponse) -> Void)? = nil) {
        completion?(runModal())
    }
    
    func beginSheetModalForWindow(_ window: NSWindow?, completion:  ((NSApplication.ModalResponse) -> Void)? = nil) {
        guard let window = window else {
            runModal(completion)
            return
        }
        beginSheetModal(for: window, completionHandler: completion)
    }
    
    convenience init(message: String?, description: String? = nil, buttons: [String] = []) {
        self.init()
        messageText = message != nil ? message! : ""
        informativeText = description != nil ? description! : ""
        for button in buttons {
            addButton(withTitle: button)
        }
    }
}

extension UserDefaults {
    var path: String {
        set {
            UserDefaults.standard.set(newValue as NSString, forKey: "path")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.object(forKey: "path") as? String ?? ""
        }
    }
}
