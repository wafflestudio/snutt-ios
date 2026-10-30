//
//  EvaluationHomeScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import SwiftUIUtility

public struct EvaluationHomeScene: View {
    @State private var viewModel = EvaluationHomeViewModel()
    @State private var searchViewModel = EvaluationSearchViewModel()
    @State private var isFilterSheetPresented = false
    @State private var menuAction: EvaluationMenuAction?
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    public init() {}

    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            ZStack {
                if searchViewModel.isPresented {
                    searchContent
                        .transition(.opacity)
                } else {
                    homeContent
                        .transition(.opacity)
                }
            }
            .animation(.smooth(duration: 0.25), value: searchViewModel.isPresented)
            .analyticsScreen(.reviewSearch, condition: searchViewModel.isPresented)
            .background(Color(uiColor: .systemBackground))
            .navigationTitle(EvaluationsStrings.homeTitle)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchViewModel.queryText,
                isPresented: $searchViewModel.isPresented,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: EvaluationsStrings.searchPrompt
            )
            .onSubmit(of: .search) {
                errorAlertHandler.withAlert {
                    try await searchViewModel.search()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(value: EvaluationDestination.myEvaluations) {
                        Label(EvaluationsStrings.homeMyEvaluations, systemImage: "person.text.rectangle")
                    }
                }
            }
            .navigationDestination(for: EvaluationDestination.self) { destination in
                destinationView(for: destination)
            }
        }
        .onChange(of: viewModel.path.isEmpty) { _, isAtRoot in
            guard isAtRoot else { return }
            errorAlertHandler.withAlert {
                try await viewModel.refresh()
            }
        }
        .sheet(isPresented: $isFilterSheetPresented) {
            EvaluationFilterSheet(selectedTags: searchViewModel.filterTags) { tags in
                errorAlertHandler.withAlert {
                    try await searchViewModel.applyFilterTags(tags)
                }
            }
        }
        .sheet(item: $viewModel.writeRequest) { request in
            EvaluationWriteScene(lectureID: request.lectureID) { evaluationID in
                errorAlertHandler.withAlert {
                    try await viewModel.didCreateEvaluation(evaluationID, for: request.lectureID)
                }
            }
        }
        .evaluationMenuActions(
            $menuAction,
            onEdit: { _ in
                errorAlertHandler.withAlert {
                    try await viewModel.refresh()
                }
            },
            onReport: { id, reason in
                errorAlertHandler.withAlert {
                    try await viewModel.reportEvaluation(id, reason: reason)
                }
            },
            onDelete: { id in
                errorAlertHandler.withAlert {
                    try await viewModel.deleteEvaluation(id)
                }
            }
        )
        .onLoad {
            await errorAlertHandler.withAlert {
                try await viewModel.load()
            }
        }
    }

    // MARK: Home

    private var homeContent: some View {
        ScrollView {
            switch viewModel.homeState {
            case .loading:
                EvaluationHomeFeed(content: EvaluationPreviewFixtures.homeContent, actions: .disabled)
                    .redacted(reason: .placeholder)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            case .loaded(let content):
                EvaluationHomeFeed(content: content, actions: homeActions)
            }
        }
        .withResponsiveTouch()
        .refreshable {
            await errorAlertHandler.withAlert {
                try await viewModel.load()
            }
        }
        .animation(.defaultSpring, value: viewModel.homeState.value == nil)
    }

    private var homeActions: EvaluationHomeFeed.Actions {
        EvaluationHomeFeed.Actions(
            selectSort: { sort in
                errorAlertHandler.withAlert {
                    try await viewModel.selectSort(sort)
                }
            },
            toggleLike: { evaluation in
                errorAlertHandler.withAlert {
                    try await viewModel.toggleLike(evaluation)
                }
            },
            openSeeAll: viewModel.openAllEvaluations,
            writeEvaluation: { viewModel.writeRequest = EvaluationWriteRequest(lectureID: $0) },
            selectMenuAction: { menuAction = $0 }
        )
    }

    // MARK: Search

    private var searchContent: some View {
        EvaluationSearchContent(
            filterTags: searchViewModel.filterTags,
            resultState: searchViewModel.resultState,
            onOpenFilters: { isFilterSheetPresented = true },
            onRemoveFilterTag: { tag in
                errorAlertHandler.withAlert {
                    try await searchViewModel.removeFilterTag(tag)
                }
            },
            onSelectResult: { result in
                viewModel.path.append(.lectureDetail(result.id, referrer: .search(query: searchViewModel.queryText)))
            },
            onResultAppear: { result in
                Task {
                    await searchViewModel.loadMoreIfNeeded(after: result)
                }
            }
        )
    }

    // MARK: Destinations

    @ViewBuilder
    private func destinationView(for destination: EvaluationDestination) -> some View {
        switch destination {
        case .lectureDetail(let lectureID, let highlightedEvaluationID, let referrer):
            EvaluationLectureDetailScene(lectureID: lectureID, highlightedEvaluationID: highlightedEvaluationID)
                .analyticsScreen(.reviewDetail(evLectureID: lectureID.rawValue, referrer: referrer))
        case .myEvaluations:
            MyEvaluationsScene()
                .analyticsScreen(.myReviews)
        case .allEvaluations(let initialSort, let availableSorts):
            EvaluationSeeAllScene(initialSort: initialSort, availableSorts: availableSorts)
                .analyticsScreen(.reviewAll(sort: initialSort.kind.rawValue))
        }
    }
}

/// The scrolling home feed, rendered from either loaded content or skeleton placeholders.
struct EvaluationHomeFeed: View {
    struct Actions {
        let selectSort: (EvaluationSort) -> Void
        let toggleLike: (LectureEvaluation) -> Void
        let openSeeAll: () -> Void
        let writeEvaluation: (EvaluationLectureID) -> Void
        let selectMenuAction: (EvaluationMenuAction) -> Void

        static var disabled: Actions {
            Actions(
                selectSort: { _ in },
                toggleLike: { _ in },
                openSeeAll: {},
                writeEvaluation: { _ in },
                selectMenuAction: { _ in }
            )
        }
    }

    let content: EvaluationHomeContent
    let actions: Actions

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            EvaluationMainFeedSection(
                selectedSort: content.selectedSort,
                availableSorts: content.availableSorts,
                items: content.mainFeed,
                onSelectSort: actions.selectSort,
                onToggleLike: actions.toggleLike,
                onOpenSeeAll: actions.openSeeAll
            )

            ForEach(content.takenLectureGroups) { group in
                EvaluationTakenLectureSection(
                    group: group,
                    onWriteEvaluation: actions.writeEvaluation,
                    onToggleLike: actions.toggleLike,
                    onSelectMenuAction: actions.selectMenuAction
                )
            }
        }
        .padding(.bottom, 24)
    }
}

#if DEBUG
#Preview("Home") {
    EvaluationHomeScene()
}

#Preview("Loading") {
    NavigationStack {
        ScrollView {
            EvaluationHomeFeed(content: EvaluationPreviewFixtures.homeContent, actions: .disabled)
                .redacted(reason: .placeholder)
        }
        .navigationTitle(EvaluationsStrings.homeTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
#endif
