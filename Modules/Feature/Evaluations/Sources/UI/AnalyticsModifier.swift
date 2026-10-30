//
//  AnalyticsModifier.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import SwiftUI

extension View {
    func analyticsScreen(_ screen: AnalyticsScreen, condition: Bool = true) -> some View {
        modifier(AnalyticsScreenModifier(screen: screen, condition: condition))
    }
}
