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
    private let onSearch: () -> Void
    private let onSelectEvaluation: (EvaluationID) -> Void

    init(
        initialSortKind: EvaluationSort.Kind,
        availableSorts: [EvaluationSort],
        onSearch: @escaping () -> Void,
        onSelectEvaluation: @escaping (EvaluationID) -> Void
    ) {
        _viewModel = State(
            initialValue: EvaluationSeeAllViewModel(
                initialSortKind: initialSortKind,
                availableSorts: availableSorts
            )
        )
        self.onSearch = onSearch
        self.onSelectEvaluation = onSelectEvaluation
    }

    var body: some View {
        content
            .background(Color(uiColor: .systemBackground))
            .onLoad {
                await errorAlertHandler.withAlert {
                    try await viewModel.load()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.loadState {
        case .loading:
            loadingContent

        case .loaded(let evaluations):
            loadedContent(evaluations)
        }
    }

    private var loadingContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                searchEntry

                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
            }
        }
        .refreshable {
            await errorAlertHandler.withAlert {
                try await viewModel.load()
            }
        }
    }

    private func loadedContent(_ evaluations: [LectureEvaluation]) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                searchEntry

                EvaluationMainFeedSection(
                    mode: .loaded(
                        feed: EvaluationFeedContent(
                            evaluations: evaluations,
                            cursor: nil,
                            canLoadMore: true
                        ),
                        selectedSort: viewModel.selectedSort,
                        availableSorts: viewModel.availableSorts
                    ),
                    onSelectSort: { sort in
                        errorAlertHandler.withAlert {
                            try await viewModel.selectSort(sort)
                        }
                    },
                    onSelectEvaluation: onSelectEvaluation,
                    onOpenSeeAll: {},
                    maximumEvaluationCount: nil,
                    showsSeeAllLink: false,
                    onEvaluationAppear: { evaluation in
                        Task {
                            await viewModel.loadMoreIfNeeded(current: evaluation)
                        }
                    }
                )
            }
        }
        .withResponsiveTouch()
        .refreshable {
            await errorAlertHandler.withAlert {
                try await viewModel.refresh()
            }
        }
        .animation(.defaultSpring, value: viewModel.selectedSort)
        .animation(.defaultSpring, value: evaluations.map(\.id))
    }

    private var searchEntry: some View {
        EvaluationSearchEntryView(
            onSearch: onSearch,
            onFilter: onSearch
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 18)
    }

}

#Preview("See All") {
    EvaluationSeeAllScene(
        initialSortKind: .recommended,
        availableSorts: EvaluationPreviewFixtures.sorts,
        onSearch: {},
        onSelectEvaluation: { _ in }
    )
}
