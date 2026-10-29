//
//  EvaluationMainFeedSection.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct EvaluationMainFeedSection: View {
    enum Mode: Equatable {
        case loading
        case loaded(
            feed: EvaluationFeedContent,
            selectedSort: EvaluationSort,
            availableSorts: [EvaluationSort]
        )

        var isLoading: Bool {
            if case .loading = self { true } else { false }
        }
    }

    let mode: Mode
    let onSelectSort: (EvaluationSort) -> Void
    let onSelectEvaluation: (EvaluationID) -> Void
    let onOpenSeeAll: () -> Void
    var maximumEvaluationCount: Int? = 2
    var showsSeeAllLink = true
    var onEvaluationAppear: (LectureEvaluation) -> Void = { _ in }

    private var feed: EvaluationFeedContent {
        switch mode {
        case .loading:
            .placeholder
        case .loaded(let feed, _, _):
            feed
        }
    }

    private var selectedSort: EvaluationSort {
        switch mode {
        case .loading:
            .placeholderRecommended
        case .loaded(_, let selectedSort, _):
            selectedSort
        }
    }

    private var availableSorts: [EvaluationSort] {
        switch mode {
        case .loading:
            [.placeholderRecommended, .placeholderLatest]
        case .loaded(_, _, let availableSorts):
            availableSorts
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            EvaluationSortToggle(
                sorts: availableSorts,
                selectedSort: selectedSort,
                onSelect: onSelectSort
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 10)

            evaluationList
                .animation(.defaultSpring, value: displayedEvaluationIDs)

            if showsSeeAllLink {
                EvaluationHomeSectionLink(title: "강의평 전체보기", action: onOpenSeeAll)
            }
        }
        .redacted(reason: mode.isLoading ? .placeholder : [])
    }

    private var displayedEvaluations: [LectureEvaluation] {
        guard let maximumEvaluationCount else {
            return feed.evaluations
        }
        return Array(feed.evaluations.prefix(maximumEvaluationCount))
    }

    private var displayedEvaluationIDs: [EvaluationID] {
        displayedEvaluations.map(\.id)
    }

    @ViewBuilder
    private var evaluationList: some View {
        if !mode.isLoading, feed.evaluations.isEmpty {
            emptyRow("아직 등록된 강의평이 없습니다.")
                .padding(.horizontal, 20)
        } else {
            ForEach(displayedEvaluations) { evaluation in
                LectureEvaluationCell(
                    evaluation: evaluation,
                    onTap: {
                        onSelectEvaluation(evaluation.id)
                    }
                )
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 14)
                .onAppear {
                    onEvaluationAppear(evaluation)
                }

                Divider()
                    .padding(.leading, 20)
            }
        }
    }

    private func emptyRow(_ message: String) -> some View {
        Text(message)
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 18)
    }
}

#Preview("Main Feed Loading") {
    EvaluationMainFeedSection(
        mode: .loading,
        onSelectSort: { _ in },
        onSelectEvaluation: { _ in },
        onOpenSeeAll: {}
    )
    .background(Color(uiColor: .systemBackground))
}

#Preview("Main Feed Loaded") {
    EvaluationMainFeedSection(
        mode: .loaded(
            feed: EvaluationPreviewFixtures.homeContent.mainFeed,
            selectedSort: EvaluationPreviewFixtures.homeContent.selectedSort,
            availableSorts: EvaluationPreviewFixtures.homeContent.availableSorts
        ),
        onSelectSort: { _ in },
        onSelectEvaluation: { _ in },
        onOpenSeeAll: {}
    )
    .background(Color(uiColor: .systemBackground))
}
