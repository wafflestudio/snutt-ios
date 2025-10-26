//
//  LiquidGlassMode.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

public func isLiquidGlassEnabled() -> Bool {
    if #available(iOS 26.0, *) {
        true
    } else {
        false
    }
}
