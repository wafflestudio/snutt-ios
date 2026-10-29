//
//  LectureEvaluationCell.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct LectureEvaluationCell: View {
    let evaluation: LectureEvaluation
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 7) {
                header
                ratingRow

                Text(evaluation.content)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    Text(evaluation.semesterDisplayText)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))

                    Spacer(minLength: 0)

                    EvaluationLikePill(
                        likeCount: evaluation.likeCount,
                        isLiked: evaluation.isLiked
                    )
                }
                .padding(.top, 6)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.animatable(scale: 0.98))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(evaluation.lecture.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text(evaluation.lecture.instructor?.nilIfEmpty ?? "교수명")
                .font(.system(size: 13))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .lineLimit(1)
        }
    }

    private var ratingRow: some View {
        HStack(spacing: 3) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: starSystemName(for: index))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(starColor(for: index))
            }
        }
        .accessibilityLabel("별점 \(String(format: "%.1f", evaluation.rating))")
    }

    private func starSystemName(for index: Int) -> String {
        let threshold = Double(index)
        if evaluation.rating >= threshold {
            return "star.fill"
        }
        if evaluation.rating >= threshold - 0.5 {
            return "star.leadinghalf.filled"
        }
        return "star"
    }

    private func starColor(for index: Int) -> Color {
        evaluation.rating >= Double(index) - 0.5 ? .yellow : Color(uiColor: .systemGray4)
    }
}

struct EvaluationLikePill: View {
    let likeCount: Int
    let isLiked: Bool

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                .font(.system(size: 11, weight: .medium))

            Text("\(likeCount)")
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundStyle(isLiked ? EvaluationDesignColor.mint : Color(uiColor: .tertiaryLabel))
        .padding(.horizontal, 10)
        .frame(height: 28)
        .background(Color(uiColor: .systemBackground))
        .overlay(
            Capsule()
                .stroke(Color(uiColor: .systemGray5), lineWidth: 1)
        )
        .clipShape(Capsule())
        .accessibilityLabel("좋아요 \(likeCount)개")
    }
}

enum EvaluationDesignColor {
    static let mint = Color(red: 0.08, green: 0.78, blue: 0.74)
    static let mintBackground = Color(red: 0.94, green: 1.0, blue: 0.99)
}

extension LectureEvaluation {
    var semesterDisplayText: String {
        "\(year % 100)년 \(semester)학기"
    }
}

extension String {
    fileprivate var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

#Preview {
    LectureEvaluationCell(
        evaluation: LectureEvaluation(
            id: EvaluationID(1),
            lecture: EvaluationLectureBrief(
                id: EvaluationLectureID(10),
                title: "컴퓨터의 개념 및 실습",
                instructor: "김교수"
            ),
            rating: 4.5,
            content: "과제가 실습 위주라 시간이 조금 걸리지만 수업 내용을 이해하는 데 도움이 됩니다.",
            year: 2025,
            semester: 2,
            likeCount: 12,
            isLiked: true,
            isReportable: true
        ),
        onTap: {}
    )
    .padding(.horizontal, 20)
}

#Preview("Like Pill") {
    EvaluationLikePill(likeCount: 12, isLiked: false)
        .padding()
}
