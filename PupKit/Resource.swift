import Foundation

protocol Resource {
    var uri: String {
        get
    }
    
    var manifest: [String] {
        get
    }
}
