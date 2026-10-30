//
//  EvaluationRatingViews.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

/// Five stars filled in half-star steps.
struct EvaluationStarRating: View {
    let rating: Double
    var starSize: CGFloat = 13

    @ScaledMetric private var spacing = 2.0

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...5, id: \.self) { index in
                EvaluationStarGlyph(fill: .init(rating: rating, position: index), size: starSize)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(EvaluationsStrings.ratingAccessibility(rating.ratingText))
    }
}

/// A single star that is empty, half filled, or fully filled.
struct EvaluationStarGlyph: View {
    enum Fill: Equatable {
        case empty
        case half
        case full

        /// The fill of the star at a 1-based `position` for a rating in half-star steps.
        init(rating: Double, position: Int) {
            if rating >= Double(position) {
                self = .full
            } else if rating >= Double(position) - 0.5 {
                self = .half
            } else {
                self = .empty
            }
        }
    }

    let fill: Fill
    let size: CGFloat

    var body: some View {
        Image(systemName: "star.fill")
            .font(.system(size: size))
            .foregroundStyle(EvaluationDesignColor.emptyStar)
            .overlay(alignment: .leading) {
                Image(systemName: "star.fill")
                    .font(.system(size: size))
                    .foregroundStyle(EvaluationDesignColor.star)
                    .mask(alignment: .leading) {
                        GeometryReader { proxy in
                            Rectangle()
                                .frame(width: proxy.size.width * fillFraction)
                        }
                    }
            }
    }

    private var fillFraction: CGFloat {
        switch fill {
        case .empty: 0
        case .half: 0.5
        case .full: 1
        }
    }
}

/// A compact average such as "★ 4.6 (15)", or a muted placeholder when there are no ratings.
struct EvaluationAverageRatingLabel: View {
    let averageRating: Double?
    var evaluationCount: Int?

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .imageScale(.small)
                .foregroundStyle(averageRating == nil ? EvaluationDesignColor.emptyStar : EvaluationDesignColor.star)

            Text(averageRating?.ratingText ?? "-")
                .fontWeight(.semibold)
                .foregroundStyle(averageRating == nil ? .secondary : .primary)

            if let evaluationCount {
                Text("(\(evaluationCount))")
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        guard let averageRating else { return EvaluationsStrings.ratingNone }
        let ratingText = EvaluationsStrings.ratingAccessibility(averageRating.ratingText)
        guard let evaluationCount else { return ratingText }
        return "\(ratingText), \(EvaluationsStrings.ratingEvaluationCountAccessibility(evaluationCount))"
    }
}

/// The four detailed criteria shown in a tinted strip.
struct EvaluationScoreStrip: View {
    let scores: EvaluationScores

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                ForEach(Array(EvaluationCriterion.allCases.enumerated()), id: \.element) { index, criterion in
                    if index > 0 {
                        Divider()
                            .frame(height: 12)
                    }
                    item(for: criterion)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 8) {
                ForEach(EvaluationCriterion.allCases, id: \.self) { criterion in
                    item(for: criterion)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(EvaluationDesignColor.accentBackground, in: .rect(cornerRadius: 8, style: .continuous))
    }

    private func item(for criterion: EvaluationCriterion) -> some View {
        HStack(spacing: 4) {
            Text(criterion.displayTitle)
                .foregroundStyle(.secondary)
            Text(scores[criterion].ratingText)
                .fontWeight(.semibold)
                .foregroundStyle(EvaluationDesignColor.accent)
                .monospacedDigit()
        }
        .font(.caption)
        .lineLimit(1)
        .fixedSize()
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        EvaluationStarRating(rating: 3.5)
        EvaluationAverageRatingLabel(averageRating: 4.6, evaluationCount: 12)
            .font(.footnote)
        EvaluationAverageRatingLabel(averageRating: nil, evaluationCount: 0)
            .font(.footnote)
        EvaluationScoreStrip(scores: EvaluationPreviewFixtures.scores)
    }
    .padding()
}
