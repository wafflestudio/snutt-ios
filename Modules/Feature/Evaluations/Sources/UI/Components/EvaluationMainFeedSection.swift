//
//  EvaluationMainFeedSection.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

/// The home feed preview: a sort toggle, a few evaluations, and a link to the full feed.
struct EvaluationMainFeedSection: View {
    let selectedSort: EvaluationSort
    let availableSorts: [EvaluationSort]
    let items: [EvaluationWithLecture]
    let onSelectSort: (EvaluationSort) -> Void
    let onToggleLike: (LectureEvaluation) -> Void
    let onOpenSeeAll: () -> Void

    private static let previewCount = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            EvaluationSortToggle(sorts: availableSorts, selectedSort: selectedSort, onSelect: onSelectSort)
                .padding(.top, 4)

            if items.isEmpty {
                Text(EvaluationsStrings.homeFeedEmpty)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                ForEach(items.prefix(Self.previewCount)) { item in
                    FeedEvaluationRow(item: item) {
                        onToggleLike(item.evaluation)
                    }
                    .transition(.opacity)
                    Divider()
                }
            }

            Button(action: onOpenSeeAll) {
                HStack(spacing: 4) {
                    Text(EvaluationsStrings.homeSeeAll)
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                }
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 48)
                .contentShape(.rect)
            }
            .buttonStyle(.animatable)
        }
        .padding(.horizontal, 20)
        .animation(.defaultSpring, value: items.map(\.id))
    }
}

/// A text toggle between feed orderings, styled as "• 추천순  • 최신순".
struct EvaluationSortToggle: View {
    let sorts: [EvaluationSort]
    let selectedSort: EvaluationSort
    let onSelect: (EvaluationSort) -> Void

    var body: some View {
        HStack(spacing: 16) {
            ForEach(sorts) { sort in
                let isSelected = sort == selectedSort
                Button {
                    onSelect(sort)
                } label: {
                    HStack(spacing: 5) {
                        Circle()
                            .frame(width: 4, height: 4)
                        Text(sort.kind.displayTitle)
                    }
                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? AnyShapeStyle(.primary) : AnyShapeStyle(.tertiary))
                    .frame(minHeight: 36)
                    .contentShape(.rect)
                }
                .buttonStyle(.animatable(hapticFeedback: true))
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
            Spacer(minLength: 0)
        }
        .animation(.defaultSpring, value: selectedSort)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            EvaluationMainFeedSection(
                selectedSort: EvaluationPreviewFixtures.sorts[0],
                availableSorts: EvaluationPreviewFixtures.sorts,
                items: EvaluationPreviewFixtures.feed,
                onSelectSort: { _ in },
                onToggleLike: { _ in },
                onOpenSeeAll: {}
            )
        }
    }
}
