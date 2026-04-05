import UIKit

extension UIView {
    public func findDescendant<T: UIView>(ofType type: T.Type) -> T? {
        for subview in subviews {
            if let match = subview as? T {
                return match
            }
            if let match = subview.findDescendant(ofType: type) {
                return match
            }
        }
        return nil
    }
}
