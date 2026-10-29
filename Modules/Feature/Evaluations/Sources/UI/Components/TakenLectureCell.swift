//
//  TakenLectureCell.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import TimetableInterface

struct TakenLectureCell: View {
    let lecture: TakenLectureSummary
    let onTap: () -> Void
    let onWrite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            if lecture.evaluations.isEmpty {
                TakenLectureEmptyPrompt(lectureTitle: lecture.lecture.title)
            } else {
                VStack(alignment: .leading, spacing: 18) {
                    ForEach(lecture.evaluations) { evaluation in
                        TakenLectureEvaluationRow(evaluation: evaluation)
                    }
                }
            }
        }
        .padding(.vertical, 24)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                onTap()
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(lecture.lecture.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.yellow)

                        Text(lecture.averageRatingDisplayText)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.primary)

                        Text("· \(lecture.lecture.instructor?.nilIfEmpty ?? "교수명")")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.animatable())

            if lecture.canWriteEvaluation {
                Button {
                    onWrite()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12, weight: .bold))
                        Text("강의평 작성")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .frame(height: 32)
                    .background(EvaluationDesignColor.mint)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
                .buttonStyle(.animatable(scale: 0.98))
            }
        }
    }
}

extension TakenLectureSummary {
    fileprivate var semesterDisplayText: String {
        "\(takenQuarter.year % 100)년 \(takenQuarter.semester.takenLectureCellDisplayTitle)"
    }

    fileprivate var averageRatingDisplayText: String {
        guard let averageRating else {
            return "(-)"
        }
        return String(format: "%.1f", averageRating)
    }
}

extension Semester {
    fileprivate var takenLectureCellDisplayTitle: String {
        switch self {
        case .first:
            "1학기"
        case .summer:
            "여름학기"
        case .second:
            "2학기"
        case .winter:
            "겨울학기"
        }
    }
}

struct TakenLectureEvaluationRow: View {
    let evaluation: LectureEvaluation

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 8) {
                Text(evaluation.semesterDisplayText)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(uiColor: .tertiaryLabel))

                Spacer(minLength: 0)

                Button {
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(uiColor: .systemGray3))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.animatable())
                .accessibilityLabel("강의평 더보기")
            }

            EvaluationStarRatingRow(rating: evaluation.rating)

            if !evaluation.scores.isEmpty {
                EvaluationScoreRow(scores: evaluation.scores)
            }

            Text(evaluation.content)
                .font(.system(size: 14))
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
    }
}

struct EvaluationStarRatingRow: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: starSystemName(for: index))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(starColor(for: index))
            }
        }
        .accessibilityLabel("별점 \(String(format: "%.1f", rating))")
    }

    private func starSystemName(for index: Int) -> String {
        if rating >= Double(index) {
            return "star.fill"
        }
        if rating >= Double(index) - 0.5 {
            return "star.leadinghalf.filled"
        }
        return "star.fill"
    }

    private func starColor(for index: Int) -> Color {
        rating >= Double(index) - 0.5 ? .yellow : Color(uiColor: .systemGray4)
    }
}

struct EvaluationScoreRow: View {
    let scores: [LectureEvaluationScore]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(scores) { score in
                HStack(spacing: 4) {
                    Text(score.title)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))

                    Text(String(format: "%.1f", score.value))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(EvaluationDesignColor.mint)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 36)
        .background(EvaluationDesignColor.mintBackground)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}

struct TakenLectureEmptyPrompt: View {
    let lectureTitle: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(EvaluationDesignColor.mint.opacity(0.14))
                    .frame(width: 32, height: 32)

                Image(systemName: "pencil")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(EvaluationDesignColor.mint)
            }

            VStack(spacing: 2) {
                Text(lectureTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(EvaluationDesignColor.mint)
                    .lineLimit(1)

                Text("첫 강의평을 남겨보세요!")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 116)
        .background(EvaluationDesignColor.mintBackground)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}

extension String {
    fileprivate var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

#Preview {
    TakenLectureCell(
        lecture: EvaluationPreviewFixtures.takenLectureFeed.lectures[0],
        onTap: {},
        onWrite: {}
    )
    .padding(.horizontal, 20)
}

#Preview("Taken Lecture Empty") {
    TakenLectureCell(
        lecture: EvaluationPreviewFixtures.takenLectureFeed.lectures[1],
        onTap: {},
        onWrite: {}
    )
    .padding(.horizontal, 20)
}

#Preview("Review Row") {
    TakenLectureEvaluationRow(evaluation: EvaluationPreviewFixtures.evaluations[0])
        .padding(.horizontal, 20)
}

#Preview("Score Row") {
    EvaluationScoreRow(scores: EvaluationPreviewFixtures.scoreSet)
        .padding()
}

#Preview("Star Rating") {
    EvaluationStarRatingRow(rating: 3.0)
        .padding()
}

#Preview("Empty Prompt") {
    TakenLectureEmptyPrompt(lectureTitle: "죽음의 과학적 이해")
        .padding()
}
