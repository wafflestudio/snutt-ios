//
//  AnalyticsScreenModifier.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import SwiftUI

public struct AnalyticsScreenModifier: ViewModifier {
    let screen: any AnalyticsLogEvent
    let condition: Bool

    public init(screen: any AnalyticsLogEvent, condition: Bool = true) {
        self.screen = screen
        self.condition = condition
    }

    public func body(content: Content) -> some View {
        content
            .onAppear {
                if condition {
                    logScreen()
                }
            }
            .onChange(of: condition) { oldValue, newValue in
                if newValue {
                    logScreen()
                }
            }
    }

    private func logScreen() {
        Dependency(\.analyticsLogger).wrappedValue.logScreen(screen)
    }
}
