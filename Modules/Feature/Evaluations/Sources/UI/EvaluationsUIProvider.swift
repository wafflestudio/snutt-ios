//
//  EvaluationsUIProvider.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import EvaluationsInterface
import SwiftUI

public struct EvaluationsUIProvider: EvaluationsUIProvidable {
    public nonisolated init() {}
    public func makeEvaluationsScene(for evLectureID: Int) -> AnyView {
        #if FEATURE_NATIVE_EVALUATIONS
        AnyView(EvaluationLectureDetailSheet(lectureID: EvaluationLectureID(Int64(evLectureID))))
        #else
        AnyView(EvaluationsWebScene(evLectureID: evLectureID))
        #endif
    }
}

/// A lecture's evaluations presented modally from outside the evaluation tab.
private struct EvaluationLectureDetailSheet: View {
    let lectureID: EvaluationLectureID
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        EvaluationEmailVerificationGate(onClose: { dismiss() }) {
            NavigationStack {
                EvaluationLectureDetailScene(lectureID: lectureID)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(EvaluationsStrings.close, systemImage: "xmark") {
                                dismiss()
                            }
                        }
                    }
            }
        }
    }
}
