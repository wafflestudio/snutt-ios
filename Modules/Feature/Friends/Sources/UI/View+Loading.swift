//
//  View+Loading.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

extension View {
    func performLoading(
        isLoading: Binding<Bool>,
        errorAlertHandler: ErrorAlertHandler,
        action: @escaping () async throws -> Void
    ) {
        guard !isLoading.wrappedValue else { return }
        withAnimation(.defaultSpring) {
            isLoading.wrappedValue = true
        }
        errorAlertHandler.withAlert {
            try await action()
            withAnimation(.defaultSpring) {
                isLoading.wrappedValue = false
            }
        }
    }
}
