import Foundation
public struct MagicKit {
    public private(set) var text = "Hello, World!"
    
    public static var test = NSLocalizedString("test-localization", bundle: Bundle.module, comment: "")

    public init() {
    }
}
