//
//  EvaluationLoadFailedView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

/// Stands in for a screen's content when its first load failed, offering a retry.
struct EvaluationLoadFailedView: View {
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(EvaluationsStrings.errorLoadFailed, systemImage: "exclamationmark.triangle")
        } description: {
            Text(EvaluationsStrings.errorRetrySuggestion)
        } actions: {
            Button(SharedUIComponentsStrings.errorViewButtonLabel, action: retry)
                .buttonStyle(.bordered)
                .tint(EvaluationDesignColor.accent)
        }
    }
}

#Preview {
    EvaluationLoadFailedView(retry: {})
}
