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
    let shouldLogEvent: () -> Bool
    let firebaseLogger = FirebaseAnalyticsLogger()

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard shouldLogEvent() else { return }
                firebaseLogger.logScreen(screen)
            }
    }
}

extension View {
    @ViewBuilder func analyticsScreen(
        _ screen: AnalyticsScreen,
        shouldLogEvent: @autoclosure @escaping () -> Bool = true
    ) -> some View {
        modifier(AnalyticsScreenModifier(screen: screen, shouldLogEvent: shouldLogEvent))
    }
}
