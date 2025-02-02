//
//  SpringAnimations.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI

public extension Animation {
    static var defaultSpring: Animation {
        spring(response: 0.2, dampingFraction: 1, blendDuration: 0)
    }
}

public extension UIView {
    static func animateSpring(animations: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            animations()
        }
    }
}
