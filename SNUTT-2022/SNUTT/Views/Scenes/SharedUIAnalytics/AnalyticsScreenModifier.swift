//
//  AnalyticsScreenModifier.swift
//  SNUTT
//
//  Created by user on 2/28/25.
//

import os
import SwiftUI

let analyticsLocalLogger = os.Logger(
    subsystem: "com.wafflestudio.snutt",
    category: "Analytics"
)

struct AnalyticsScreenModifier: ViewModifier {
    let screen: AnalyticsScreen
    let firebaseLogger = FirebaseAnalyticsLogger()

    func body(content: Content) -> some View {
        content
            .onAppear {
                firebaseLogger.logScreen(screen)
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
