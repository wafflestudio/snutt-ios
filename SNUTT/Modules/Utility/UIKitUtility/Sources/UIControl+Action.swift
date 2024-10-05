//
//  UIControl+Action.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import UIKit

extension UIControl {
    public func addAction(
        for controlEvents: UIControl.Event = .touchUpInside,
        _ closure: @MainActor @escaping () -> Void
    ) {
        addAction(UIAction { (action: UIAction) in closure() }, for: controlEvents)
    }
}
