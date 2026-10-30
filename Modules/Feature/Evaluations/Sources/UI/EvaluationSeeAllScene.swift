//
//  EvaluationSeeAllScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import SwiftUIUtility

struct EvaluationSeeAllScene: View {
    @State private var viewModel: EvaluationSeeAllViewModel
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    init(initialSort: EvaluationSort, availableSorts: [EvaluationSort]) {
        _viewModel = State(
            initialValue: EvaluationSeeAllViewModel(initialSort: initialSort, availableSorts: availableSorts)
        )
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                switch viewModel.feedState {
                case .loading:
                    rows(EvaluationPreviewFixtures.feed)
                        .redacted(reason: .placeholder)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                case .loaded(let content):
                    rows(content.items)
                }
            }
        }
        .withResponsiveTouch()
        .refreshable {
            await errorAlertHandler.withAlert {
                try await viewModel.load()
            }
        }
        // A bar, like the search filter chips, so the feed scrolls under it with the system edge effect.
        .topBar {
            EvaluationSortChipBar(
                sorts: viewModel.availableSorts,
                selectedSort: viewModel.selectedSort,
                onSelect: { sort in
                    errorAlertHandler.withAlert {
                        try await viewModel.selectSort(sort)
                    }
                }
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .animation(.defaultSpring, value: viewModel.feedState)
        .background(Color(uiColor: .systemBackground))
        .navigationTitle(EvaluationsStrings.seeAllTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onLoad {
            await errorAlertHandler.withAlert {
                try await viewModel.load()
            }
        }
    }

    private func rows(_ items: [EvaluationWithLecture]) -> some View {
        ForEach(items) { item in
            FeedEvaluationRow(item: item) {
                errorAlertHandler.withAlert {
                    try await viewModel.toggleLike(item.evaluation)
                }
            }
            .padding(.horizontal, 20)
            .onAppear {
                Task {
                    await viewModel.loadMoreIfNeeded(after: item)
                }
            }

            Divider()
                .padding(.horizontal, 20)
        }
    }
}

/// Feed orderings as chips, styled like the search filter chips.
private struct EvaluationSortChipBar: View {
    let sorts: [EvaluationSort]
    let selectedSort: EvaluationSort
    let onSelect: (EvaluationSort) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(sorts) { sort in
                let isSelected = sort == selectedSort
                Button {
                    onSelect(sort)
                } label: {
                    Text(sort.kind.displayTitle)
                        .font(.footnote.weight(isSelected ? .semibold : .medium))
                        .foregroundStyle(isSelected ? EvaluationDesignColor.accent : .secondary)
                        .filterChipStyle(
                            tint: isSelected ? EvaluationDesignColor.accent : nil,
                            fallbackFill: isSelected
                                ? EvaluationDesignColor.accentBackground : Color(uiColor: .secondarySystemFill)
                        )
                }
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
            Spacer(minLength: 0)
        }
        .filterChipButtonStyle()
        .glassEffectContainerIfAvailable(spacing: 8)
        .animation(.defaultSpring, value: selectedSort)
    }
}

#Preview {
    NavigationStack {
        EvaluationSeeAllScene(
            initialSort: EvaluationPreviewFixtures.sorts[0],
            availableSorts: EvaluationPreviewFixtures.sorts
        )
    }
}
