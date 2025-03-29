//
//  ScrollView+Extensions.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//
// This extension enhances UIScrollView by providing customizable behavior
// for touch event handling. It includes methods to swizzle the default
// implementation of touchesShouldCancel(in:) and to make UIScrollView
// instances more responsive to touch events.

import UIKit
import SwiftUI
import SwiftUIIntrospect

extension ScrollView {
    @MainActor
    public func withResponsiveTouch() -> some View {
        introspect(.scrollView, on: .iOS(.v17, .v18)) { scrollView in
            scrollView.makeTouchResponsive()
        }
    }
}

extension UIScrollView {
    @MainActor
    private enum AssociatedKeys {
        static var shouldAlwaysCancelTouchesKey = 0
    }

    private static var hasSwizzled = false

    fileprivate func makeTouchResponsive() {
        UIScrollView.swizzleTouchesShouldCancel()
        delaysContentTouches = false
        shouldAlwaysCancelTouches = true
    }

    private static func swizzleTouchesShouldCancel() {
        guard !hasSwizzled,
              let originalMethod = class_getInstanceMethod(UIScrollView.self, #selector(touchesShouldCancel(in:))),
              let swizzledMethod = class_getInstanceMethod(UIScrollView.self, #selector(swizzled_touchesShouldCancel(in:)))
        else {
            return
        }

        method_exchangeImplementations(originalMethod, swizzledMethod)
        hasSwizzled = true
    }

    @objc private func swizzled_touchesShouldCancel(in view: UIView) -> Bool {
        if shouldAlwaysCancelTouches {
            return true
        } else {
            // Call the original implementation
            return swizzled_touchesShouldCancel(in: view)
        }
    }

    private var shouldAlwaysCancelTouches: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.shouldAlwaysCancelTouchesKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.shouldAlwaysCancelTouchesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
