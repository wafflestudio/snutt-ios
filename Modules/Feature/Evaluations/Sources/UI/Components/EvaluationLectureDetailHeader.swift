//
//  EvaluationLectureDetailHeader.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct EvaluationLectureDetailHeader: View {
    let detail: EvaluationLectureDetailContent

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleBlock

            Divider()
                .padding(.top, 28)
                .padding(.horizontal, 20)

            scoreSummary
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 26)
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(detail.lecture.title)
                .font(.system(size: 25, weight: .bold))
                .foregroundStyle(.primary)

            Text(detail.lecture.instructor?.nilIfEmpty ?? "교수명")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color(uiColor: .secondaryLabel))

            Text(detail.lectureMetaText)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(uiColor: .tertiaryLabel))
                .padding(.top, 2)
        }
        .padding(.horizontal, 20)
        .padding(.top, 32)
    }

    private var scoreSummary: some View {
        HStack(alignment: .top, spacing: 2) {
            EvaluationLectureAverageRating(
                rating: detail.averageRating,
                reviewCount: detail.reviewCount
            )
            .frame(width: 136, alignment: .leading)

            LazyVGrid(
                columns: [
                    GridItem(.fixed(100), spacing: 18, alignment: .leading),
                    GridItem(.fixed(104), spacing: 0, alignment: .leading),
                ],
                alignment: .leading,
                spacing: 12
            ) {
                ForEach(detail.scoreSummary) { score in
                    EvaluationLectureScoreSummaryItem(score: score)
                }
            }
            .frame(width: 222, alignment: .leading)
        }
    }
}

private struct EvaluationLectureAverageRating: View {
    let rating: Double
    let reviewCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(String(format: "%.1f", rating))
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(.primary)

                Text("(\(reviewCount))")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .tertiaryLabel))
            }

            EvaluationStarRatingRow(rating: rating)
        }
    }
}

private struct EvaluationLectureScoreSummaryItem: View {
    let score: LectureEvaluationScore

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Image(systemName: "star.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.yellow)

            Text(String(format: "%.1f", score.value))
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)
                .fixedSize()

            Text(score.title)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .lineLimit(1)
                .fixedSize()
        }
    }
}

extension String {
    fileprivate var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

#Preview {
    EvaluationLectureDetailHeader(detail: EvaluationLectureDetailPreviewHelper.detail)
}
