//
//  AnalyticsScreenModifier.swift
//  SNUTT
//
//  Created by user on 2/28/25.
//

import FirebaseAnalytics
import os
import SwiftUI

let analyticsLocalLogger = os.Logger(
    subsystem: "com.wafflestudio.snutt",
    category: "Analytics"
)

struct AnalyticsScreenModifier: ViewModifier {
    let screen: AnalyticsScreen

    func body(content: Content) -> some View {
        content
            .analyticsScreen(name: screen.snakeCase, extraParameters: screen.extraParameters)
            .onAppear {
                analyticsLocalLogger
                    .trace("[AnalyticsScreen] \(screen.snakeCase) recorded with \(screen.extraParameters).")
            }
    }
}

extension View {
    @ViewBuilder func analyticsScreen(_ screen: AnalyticsScreen, isVisible: Bool = true) -> some View {
        if isVisible {
            modifier(AnalyticsScreenModifier(screen: screen))
        } else {
            self
        }
    }
}
