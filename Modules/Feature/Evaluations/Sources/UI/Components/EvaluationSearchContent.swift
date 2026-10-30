//
//  EvaluationSearchContent.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

/// The surface shown in place of the home feed while search is active.
struct EvaluationSearchContent: View {
    let filterTags: [SearchTag]
    let resultState: EvaluationSearchViewModel.ResultState
    let onOpenFilters: () -> Void
    let onRemoveFilterTag: (SearchTag) -> Void
    let onSelectResult: (LectureSearchResult) -> Void
    let onResultAppear: (LectureSearchResult) -> Void

    var body: some View {
        VStack(spacing: 0) {
            EvaluationFilterChipBar(tags: filterTags, onOpenFilters: onOpenFilters, onRemove: onRemoveFilterTag)
                .padding(.vertical, 8)
            results
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .animation(.defaultSpring, value: filterTags)
        .animation(.smooth(duration: 0.25), value: resultState)
    }

    @ViewBuilder
    private var results: some View {
        switch resultState {
        case .idle:
            ContentUnavailableView {
                Label(EvaluationsStrings.searchIdleTitle, systemImage: "magnifyingglass")
            } description: {
                Text(EvaluationsStrings.searchIdleDescription)
            }
            .transition(.opacity)

        case .loading:
            resultList(EvaluationPreviewFixtures.searchResults)
                .redacted(reason: .placeholder)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

        case .loaded(let searchResults) where searchResults.results.isEmpty:
            ContentUnavailableView {
                Label(EvaluationsStrings.searchEmptyTitle, systemImage: "exclamationmark.magnifyingglass")
            } description: {
                Text(EvaluationsStrings.searchEmptyDescription)
            }
            .transition(.opacity)

        case .loaded(let searchResults):
            resultList(searchResults.results)
        }
    }

    private func resultList(_ results: [LectureSearchResult]) -> some View {
        List {
            ForEach(results) { result in
                Button {
                    onSelectResult(result)
                } label: {
                    EvaluationSearchResultRow(result: result)
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                .onAppear {
                    onResultAppear(result)
                }
            }
        }
        .listStyle(.plain)
        .listSectionSeparator(.hidden, edges: .top)
        .scrollDismissesKeyboard(.immediately)
    }
}

struct EvaluationSearchResultRow: View {
    let result: LectureSearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(result.info.brief.title)
                .font(.callout.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)

            HStack(spacing: 4) {
                EvaluationAverageRatingLabel(
                    averageRating: result.evaluationCount > 0 ? result.averageRating : nil,
                    evaluationCount: result.evaluationCount > 0 ? result.evaluationCount : nil
                )
                Text("·")
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
                Text(result.info.brief.instructorDisplayText)
                    .foregroundStyle(.secondary)
            }
            .font(.footnote)
            .lineLimit(1)

            if !result.info.metadataText.isEmpty {
                Text(result.info.metadataText)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}

/// A button that opens the filter sheet, followed by removable chips for the active filters.
struct EvaluationFilterChipBar: View {
    let tags: [SearchTag]
    let onOpenFilters: () -> Void
    let onRemove: (SearchTag) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                Button(action: onOpenFilters) {
                    HStack(spacing: 4) {
                        Image(systemName: "line.3.horizontal.decrease")
                        Text(EvaluationsStrings.filterTitle)
                        if !tags.isEmpty {
                            Text(tags.count, format: .number)
                                .foregroundStyle(EvaluationDesignColor.accent)
                                .contentTransition(.numericText(value: Double(tags.count)))
                        }
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(uiColor: .secondarySystemFill), in: .capsule)
                }
                .buttonStyle(.animatable(scale: 0.94))
                .accessibilityValue(tags.isEmpty ? "" : EvaluationsStrings.filterActiveAccessibility(tags.count))

                ForEach(tags) { tag in
                    Button {
                        onRemove(tag)
                    } label: {
                        SearchFilterChip(
                            title: tag.name,
                            foregroundColor: EvaluationDesignColor.accent,
                            backgroundColor: EvaluationDesignColor.accentBackground,
                            borderColor: EvaluationDesignColor.accent.opacity(0.5),
                            font: .footnote.weight(.medium),
                            iconFont: .caption2.weight(.semibold),
                            spacing: 4,
                            horizontalPadding: 12,
                            verticalPadding: 6
                        )
                    }
                    .buttonStyle(.animatable(scale: 0.94))
                    .accessibilityLabel(EvaluationsStrings.filterRemoveAccessibility(tag.name))
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview("Idle") {
    EvaluationSearchContent(
        filterTags: [],
        resultState: .idle,
        onOpenFilters: {},
        onRemoveFilterTag: { _ in },
        onSelectResult: { _ in },
        onResultAppear: { _ in }
    )
}

#Preview("Loading") {
    EvaluationSearchContent(
        filterTags: Array(EvaluationPreviewFixtures.tagGroups[0].tags.prefix(2)),
        resultState: .loading,
        onOpenFilters: {},
        onRemoveFilterTag: { _ in },
        onSelectResult: { _ in },
        onResultAppear: { _ in }
    )
}

#Preview("Results") {
    EvaluationSearchContent(
        filterTags: Array(EvaluationPreviewFixtures.tagGroups[2].tags.prefix(2)),
        resultState: .loaded(
            .init(
                query: LectureSearchQuery(text: "인공지능", tags: []),
                results: EvaluationPreviewFixtures.searchResults,
                nextPage: nil
            )
        ),
        onOpenFilters: {},
        onRemoveFilterTag: { _ in },
        onSelectResult: { _ in },
        onResultAppear: { _ in }
    )
}
