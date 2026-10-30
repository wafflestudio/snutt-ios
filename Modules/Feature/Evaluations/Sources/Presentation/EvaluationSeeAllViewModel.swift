//
//  EvaluationSeeAllViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import Dependencies
import Observation

@MainActor
@Observable
final class EvaluationSeeAllViewModel {
    private(set) var feedState: LoadState<PagedContent<EvaluationWithLecture>> = .loading
    private(set) var selectedSort: EvaluationSort
    let availableSorts: [EvaluationSort]

    @ObservationIgnored
    @Dependency(\.evaluationRepository) private var repository

    @ObservationIgnored
    @Dependency(\.analyticsLogger) private var analyticsLogger

    @ObservationIgnored
    private var isLoadingMore = false

    init(initialSort: EvaluationSort, availableSorts: [EvaluationSort]) {
        self.selectedSort = initialSort
        self.availableSorts = availableSorts
    }

    func load() async throws {
        let sort = selectedSort
        let page = try await repository.fetchEvaluations(sort: sort, cursor: nil)
        guard selectedSort == sort else { return }
        feedState = .loaded(PagedContent(page))
    }

    /// Switches sorts optimistically, keeping the previous feed visible until the new one arrives.
    func selectSort(_ sort: EvaluationSort) async throws {
        guard selectedSort != sort else { return }
        let previousSort = selectedSort
        selectedSort = sort
        do {
            try await load()
        } catch {
            if selectedSort == sort { selectedSort = previousSort }
            throw error
        }
    }

    /// Pagination is driven by scrolling, so failures stay silent and the next scroll retries.
    func loadMoreIfNeeded(after item: EvaluationWithLecture) async {
        guard case .loaded(let content) = feedState,
            let cursor = content.nextCursor,
            content.items.suffix(5).contains(where: { $0.id == item.id }),
            !isLoadingMore
        else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        let sort = selectedSort
        guard let page = try? await repository.fetchEvaluations(sort: sort, cursor: cursor),
            selectedSort == sort,
            case .loaded(let currentContent) = feedState,
            currentContent.nextCursor == cursor
        else { return }
        feedState = .loaded(currentContent.appending(page))
    }

    func toggleLike(_ evaluation: LectureEvaluation) async throws {
        let toggledLike = evaluation.like.toggled()
        updateEvaluation(evaluation.id) { $0.like = toggledLike }
        do {
            try await repository.setLiked(toggledLike.isLiked, evaluationID: evaluation.id)
            analyticsLogger.logEvent(
                AnalyticsAction.likeReview(evaluationID: evaluation.id, isLiked: toggledLike.isLiked)
            )
        } catch {
            updateEvaluation(evaluation.id) { $0.like = evaluation.like }
            throw error
        }
    }

    private func updateEvaluation(_ id: EvaluationID, _ transform: (inout LectureEvaluation) -> Void) {
        guard case .loaded(var content) = feedState else { return }
        content.update(id) { transform(&$0.evaluation) }
        feedState = .loaded(content)
    }
}
