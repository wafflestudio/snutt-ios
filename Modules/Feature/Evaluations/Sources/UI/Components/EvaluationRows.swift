//
//  EvaluationRows.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

/// A feed entry that leads with its lecture, used where evaluations of many lectures are mixed.
struct FeedEvaluationRow: View {
    let item: EvaluationWithLecture
    let onToggleLike: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            NavigationLink(value: EvaluationDestination.lectureDetail(item.lecture.id)) {
                VStack(alignment: .leading, spacing: 6) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.lecture.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                        Text(item.lecture.instructorDisplayText)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    EvaluationStarRating(rating: item.evaluation.rating)

                    Text(item.evaluation.content.singleLinePreview)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.animatable(scale: 0.98))
            .accessibilityElement(children: .combine)

            HStack {
                Text(item.evaluation.quarter.evaluationDisplayText)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                Spacer(minLength: 0)
                EvaluationLikeButton(like: item.evaluation.like, action: onToggleLike)
            }
        }
        .padding(.vertical, 16)
    }
}

/// A single evaluation of a known lecture, with detailed scores and actions.
struct EvaluationRow: View {
    let evaluation: LectureEvaluation
    var contentLineLimit: Int?
    /// Hidden where a surrounding section already names the semester.
    var showsQuarter = true
    let onToggleLike: () -> Void
    let onSelectMenuAction: (EvaluationMenuAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if showsQuarter {
                HStack {
                    Text(evaluation.quarter.evaluationDisplayText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                    EvaluationMenuButton(evaluation: evaluation, onSelect: onSelectMenuAction)
                }
                .frame(minHeight: 28)

                EvaluationStarRating(rating: evaluation.rating, starSize: 14)
                    .padding(.top, -6)
            } else {
                HStack {
                    EvaluationStarRating(rating: evaluation.rating, starSize: 14)
                    Spacer(minLength: 0)
                    EvaluationMenuButton(evaluation: evaluation, onSelect: onSelectMenuAction)
                }
                .frame(minHeight: 28)
            }

            if let scores = evaluation.scores {
                EvaluationScoreStrip(scores: scores)
            }

            if let contentLineLimit {
                Text(evaluation.content.singleLinePreview)
                    .font(.subheadline)
                    .foregroundStyle(.primary.opacity(0.8))
                    .lineLimit(contentLineLimit)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ExpandableEvaluationText(text: evaluation.content)
            }

            HStack {
                Spacer(minLength: 0)
                EvaluationLikeButton(like: evaluation.like, action: onToggleLike)
            }
        }
    }
}

/// Full evaluation text that starts collapsed and expands in place when it is too long.
private struct ExpandableEvaluationText: View {
    let text: String

    @State private var isExpanded = false
    @State private var collapsedHeight: CGFloat = 0
    @State private var fullHeight: CGFloat = 0

    private static let collapsedLineLimit = 5

    private var isTruncated: Bool {
        fullHeight > collapsedHeight + 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            styledText
                .lineLimit(isExpanded ? nil : Self.collapsedLineLimit)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onGeometryChange(for: CGFloat.self, of: \.size.height) { height in
                    if !isExpanded { collapsedHeight = height }
                }
                .background(alignment: .top) {
                    // Measures the untruncated height to decide whether the expand button is needed.
                    styledText
                        .fixedSize(horizontal: false, vertical: true)
                        .hidden()
                        .onGeometryChange(for: CGFloat.self, of: \.size.height) { height in
                            fullHeight = height
                        }
                }

            if isTruncated, !isExpanded {
                Button(EvaluationsStrings.contentMore) {
                    withAnimation(.defaultSpring) {
                        isExpanded = true
                    }
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .buttonStyle(.plain)
            }
        }
    }

    private var styledText: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.primary.opacity(0.8))
            .lineSpacing(3)
    }
}

#Preview("Feed Row") {
    NavigationStack {
        FeedEvaluationRow(item: EvaluationPreviewFixtures.feed[0], onToggleLike: {})
            .padding(.horizontal, 20)
    }
}

#Preview("Evaluation Row") {
    EvaluationRow(
        evaluation: EvaluationPreviewFixtures.feed[1].evaluation,
        onToggleLike: {},
        onSelectMenuAction: { _ in }
    )
    .padding(.horizontal, 20)
}
