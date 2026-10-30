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
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                Section {
                    switch viewModel.feedState {
                    case .loading:
                        rows(EvaluationPreviewFixtures.feed)
                            .redacted(reason: .placeholder)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    case .loaded(let content):
                        rows(content.items)
                    }
                } header: {
                    EvaluationSortToggle(
                        sorts: viewModel.availableSorts,
                        selectedSort: viewModel.selectedSort,
                        onSelect: { sort in
                            errorAlertHandler.withAlert {
                                try await viewModel.selectSort(sort)
                            }
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                    .background(Color(uiColor: .systemBackground))
                }
            }
        }
        .withResponsiveTouch()
        .refreshable {
            await errorAlertHandler.withAlert {
                try await viewModel.load()
            }
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

#Preview {
    NavigationStack {
        EvaluationSeeAllScene(
            initialSort: EvaluationPreviewFixtures.sorts[0],
            availableSorts: EvaluationPreviewFixtures.sorts
        )
    }
}
