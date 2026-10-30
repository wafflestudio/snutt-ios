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
        results
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .topBar {
                EvaluationFilterChipBar(tags: filterTags, onOpenFilters: onOpenFilters, onRemove: onRemoveFilterTag)
                    .padding(.bottom, 8)
            }
            .animation(.defaultSpring, value: filterTags)
            .animation(.smooth(duration: 0.25), value: resultState)
    }

    /// One list for every state, so the scroll view (and the bar attached to it) keeps its identity
    /// while results reload; only the rows and the overlaid placeholder change.
    private var results: some View {
        List {
            switch resultState {
            case .idle:
                EmptyView()
            case .loading:
                resultRows(EvaluationPreviewFixtures.searchResults)
                    .redacted(reason: .placeholder)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            case .loaded(let searchResults):
                resultRows(searchResults.results)
            }
        }
        .listStyle(.plain)
        .listSectionSeparator(.hidden, edges: .top)
        .scrollDismissesKeyboard(.immediately)
        .overlay {
            placeholder
                .transition(.opacity)
        }
    }

    @ViewBuilder
    private var placeholder: some View {
        switch resultState {
        case .idle:
            ContentUnavailableView {
                Label(EvaluationsStrings.searchIdleTitle, systemImage: "magnifyingglass")
            } description: {
                Text(EvaluationsStrings.searchIdleDescription)
            }
        case .loaded(let searchResults) where searchResults.results.isEmpty:
            ContentUnavailableView {
                Label(EvaluationsStrings.searchEmptyTitle, systemImage: "exclamationmark.magnifyingglass")
            } description: {
                Text(EvaluationsStrings.searchEmptyDescription)
            }
        case .loading, .loaded:
            EmptyView()
        }
    }

    private func resultRows(_ results: [LectureSearchResult]) -> some View {
        ForEach(results) { result in
            Button {
                onSelectResult(result)
            } label: {
                EvaluationSearchResultRow(result: result)
            }
            .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
            // Hiding a top edge also hides the separator shared with the previous row, so only the first row hides it.
            .listRowSeparator(result.id == results.first?.id ? .hidden : .automatic, edges: .top)
            .onAppear {
                onResultAppear(result)
            }
        }
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
                    .filterChipStyle(fallbackFill: Color(uiColor: .secondarySystemFill))
                }
                .accessibilityValue(tags.isEmpty ? "" : EvaluationsStrings.filterActiveAccessibility(tags.count))

                ForEach(tags) { tag in
                    Button {
                        onRemove(tag)
                    } label: {
                        HStack(spacing: 4) {
                            Text(tag.name)
                                .font(.footnote.weight(.medium))
                                .lineLimit(1)
                            Image(systemName: "xmark")
                                .font(.caption2.weight(.semibold))
                        }
                        .foregroundStyle(EvaluationDesignColor.accent)
                        .filterChipStyle(
                            tint: EvaluationDesignColor.accent,
                            fallbackFill: EvaluationDesignColor.accentBackground
                        )
                    }
                    .accessibilityLabel(EvaluationsStrings.filterRemoveAccessibility(tag.name))
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
            }
            .filterChipButtonStyle()
            .glassEffectContainerIfAvailable(spacing: 8)
            // Lines the chips up with the search field above them.
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        // Leaves room for the chips' glass shadows, which a horizontal scroll view would otherwise clip.
        .scrollClipDisabled()
    }
}

extension View {
    /// Places bar content above a scrolling view: as a bar with the system scroll edge effect on iOS 26,
    /// and as an opaque inset before that.
    @ViewBuilder
    func topBar(@ViewBuilder _ content: () -> some View) -> some View {
        if #available(iOS 26, *) {
            safeAreaBar(edge: .top, content: content)
        } else {
            safeAreaInset(edge: .top, spacing: 0) {
                content()
                    .background(Color(uiColor: .systemBackground))
            }
        }
    }

    /// A capsule chip: Liquid Glass (optionally tinted) on iOS 26, a flat fill with a hairline before that.
    @ViewBuilder
    func filterChipStyle(tint: Color? = nil, fallbackFill: Color) -> some View {
        let chip = fixedSize()
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        if #available(iOS 26, *) {
            chip
                .glassEffect(
                    tint.map { Glass.regular.tint($0.opacity(0.18)) }?.interactive() ?? .regular.interactive(),
                    in: .capsule
                )
        } else {
            chip
                .background(fallbackFill, in: .capsule)
                .overlay {
                    if let tint {
                        Capsule()
                            .strokeBorder(tint.opacity(0.5))
                    }
                }
        }
    }

    /// Interactive glass already reacts to touches, so chips only scale themselves before iOS 26.
    @ViewBuilder
    func filterChipButtonStyle() -> some View {
        if #available(iOS 26, *) {
            buttonStyle(.plain)
        } else {
            buttonStyle(.animatable(scale: 0.94))
        }
    }

    @ViewBuilder
    func glassEffectContainerIfAvailable(spacing: CGFloat) -> some View {
        if #available(iOS 26, *) {
            GlassEffectContainer(spacing: spacing) {
                self
            }
        } else {
            self
        }
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
