//
//  EvaluationLectureDetailList.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct EvaluationLectureDetailList: View {
    let evaluations: [LectureEvaluation]

    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(evaluations.enumerated()), id: \.element.id) { index, evaluation in
                EvaluationLectureDetailRow(evaluation: evaluation)
                    .padding(.horizontal, 20)

                if index < evaluations.count - 1 {
                    Divider()
                        .padding(.horizontal, 20)
                }
            }
        }
    }
}

private struct EvaluationLectureDetailRow: View {
    let evaluation: LectureEvaluation

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            header

            EvaluationStarRatingRow(rating: evaluation.rating)

            if !evaluation.scores.isEmpty {
                EvaluationScoreRow(scores: evaluation.scores)
            }

            Text(evaluation.content)
                .font(.system(size: 17, weight: .medium))
                .lineSpacing(6)
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Spacer(minLength: 0)

                EvaluationLikePill(
                    likeCount: evaluation.likeCount,
                    isLiked: evaluation.isLiked
                )
            }
        }
        .padding(.top, 22)
        .padding(.bottom, 20)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(evaluation.semesterDisplayText)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color(uiColor: .tertiaryLabel))

            Spacer(minLength: 0)

            Button {
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color(uiColor: .systemGray3))
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.animatable())
            .accessibilityLabel("강의평 더보기")
        }
    }
}

#Preview {
    EvaluationLectureDetailList(evaluations: EvaluationLectureDetailPreviewHelper.detail.evaluations)
}
