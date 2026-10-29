//
//  EvaluationLectureDetailScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct EvaluationLectureDetailScene: View {
    let detail: EvaluationLectureDetailContent

    init(detail: EvaluationLectureDetailContent) {
        self.detail = detail
    }

    init(lectureID: EvaluationLectureID) {
        self.detail = .empty(lectureID: lectureID)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                EvaluationLectureDetailHeader(detail: detail)
                EvaluationLectureDetailSortBar()
                EvaluationLectureDetailList(evaluations: detail.evaluations)
            }
        }
        .background(Color(uiColor: .systemBackground))
        .safeAreaInset(edge: .bottom, spacing: 0) {
            EvaluationLectureDetailWriteButton(action: {})
                .padding(.bottom, 28)
        }
        .navigationTitle("강의평 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .tabBar)
    }
}

#Preview {
    NavigationStack {
        EvaluationLectureDetailScene(detail: EvaluationLectureDetailPreviewHelper.detail)
    }
}
