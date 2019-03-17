import UIKit

/// Cusotm Activity Indicator can be used by implementing this protocol
public protocol ActivityIndicatorView {
    /// View of the activity indicator
    var view: UIView { get }
    
    /// Show activity indicator
    func show()
    
    /// Hide activity indicator
    func hide()
}

/// Factory protocol to create new ActivityIndicatorViews. Meant to be implemented when creating custom activity indicator.
public protocol ActivityIndicatorFactory {
    func create() -> ActivityIndicatorView
}

/// Default ActivityIndicatorView implementation for UIActivityIndicatorView
extension UIActivityIndicatorView: ActivityIndicatorView {
    public var view: UIView {
        return self
    }
    
    public func show() {
        self.startAnimating()
    }
    
    public func hide() {
        self.stopAnimating()
    }
}

/// Default activity indicator factory creating UIActivityIndicatorView instances
@objcMembers
open class DefaultActivityIndicator: ActivityIndicatorFactory {
    /// activity indicator style
    open var style: UIActivityIndicatorView.Style
    /// activity indicator color
    open var color: UIColor?
    
    /// Create a new ActivityIndicator for UIActivityIndicatorView
    ///
    /// - style: activity indicator style
    /// - color: activity indicator color
    public init(style: UIActivityIndicatorView.Style = .gray, color: UIColor? = nil) {
        self.style = UIActivityIndicatorView.Style.whiteLarge
        self.color = UIColor.white
    }
    
    /// create ActivityIndicatorView instance
    open func create() -> ActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.color = color
        activityIndicator.hidesWhenStopped = true
        
        return activityIndicator
    }
}
