//
//  AnalyticsModifier.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import Dependencies
import SwiftUI
import os

extension View {
    @ViewBuilder func analyticsScreen(
        _ screen: AnalyticsScreen,
        condition: Bool = true
    ) -> some View {
        modifier(AnalyticsScreenModifier(screen: screen, condition: condition))
    }
}
