//
//  EvaluationSeeAllViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Observation

@MainActor
@Observable
final class EvaluationSeeAllViewModel {
    var loadState: LoadState<[LectureEvaluation]> = .loading
    var selectedSort: EvaluationSort
    let availableSorts: [EvaluationSort]

    @ObservationIgnored
    private let useCase: EvaluationHomeUseCase
    private var cursor: String?
    private var canLoadMore = true
    private var isLoadingMore = false
    private var firstPageRequestID = 0

    var loadedEvaluations: [LectureEvaluation] {
        guard case .loaded(let evaluations) = loadState else {
            return []
        }
        return evaluations
    }

    init(
        initialSortKind: EvaluationSort.Kind,
        availableSorts: [EvaluationSort]
    ) {
        let initialSort =
            availableSorts.first { $0.kind == initialSortKind }
            ?? availableSorts.first
            ?? EvaluationSort(id: -1, kind: initialSortKind)

        self.selectedSort = initialSort
        self.availableSorts = availableSorts.isEmpty ? [initialSort] : availableSorts

        @Dependency(\.evaluationRepository) var evaluationRepository
        self.useCase = EvaluationHomeUseCase(repository: evaluationRepository)
    }

    func load() async throws {
        let requestedSort = selectedSort
        let requestID = nextFirstPageRequestID()
        loadState = .loading
        cursor = nil
        canLoadMore = true
        isLoadingMore = false

        let page = try await useCase.loadEvaluations(sort: requestedSort, cursor: nil)
        guard selectedSort == requestedSort,
            firstPageRequestID == requestID
        else { return }
        cursor = page.cursor
        canLoadMore = !page.isLast
        loadState = .loaded(page.evaluations)
    }

    func refresh() async throws {
        let requestedSort = selectedSort
        let requestID = nextFirstPageRequestID()
        let page = try await useCase.loadEvaluations(sort: requestedSort, cursor: nil)
        guard selectedSort == requestedSort,
            firstPageRequestID == requestID
        else { return }
        cursor = page.cursor
        canLoadMore = !page.isLast
        isLoadingMore = false
        loadState = .loaded(page.evaluations)
    }

    func selectSort(_ sort: EvaluationSort) async throws {
        guard case .loaded(let previousEvaluations) = loadState,
            selectedSort != sort
        else { return }

        let previousSort = selectedSort
        let previousCursor = cursor
        let previousCanLoadMore = canLoadMore
        let previousFirstPageRequestID = firstPageRequestID

        selectedSort = sort
        let requestID = nextFirstPageRequestID()
        loadState = .loading
        cursor = nil
        canLoadMore = true
        isLoadingMore = false

        do {
            let page = try await useCase.loadEvaluations(sort: sort, cursor: nil)
            guard selectedSort == sort,
                firstPageRequestID == requestID
            else { return }
            cursor = page.cursor
            canLoadMore = !page.isLast
            loadState = .loaded(page.evaluations)
        } catch {
            guard selectedSort == sort,
                firstPageRequestID == requestID
            else { return }
            selectedSort = previousSort
            loadState = .loaded(previousEvaluations)
            cursor = previousCursor
            canLoadMore = previousCanLoadMore
            isLoadingMore = false
            firstPageRequestID = previousFirstPageRequestID
            throw error
        }
    }

    func loadMoreIfNeeded(current evaluation: LectureEvaluation) async {
        let currentEvaluations = loadedEvaluations
        guard canLoadMore,
            !isLoadingMore,
            currentEvaluations.last?.id == evaluation.id
        else { return }

        let requestedSort = selectedSort
        let requestedCursor = cursor
        let requestID = firstPageRequestID

        isLoadingMore = true
        defer {
            isLoadingMore = false
        }

        do {
            let page = try await useCase.loadEvaluations(
                sort: requestedSort,
                cursor: requestedCursor
            )
            guard selectedSort == requestedSort,
                cursor == requestedCursor,
                firstPageRequestID == requestID
            else { return }

            let mergedEvaluations = (loadedEvaluations + page.evaluations).removingDuplicateIDs()
            cursor = page.cursor
            canLoadMore = !page.isLast
            loadState = .loaded(mergedEvaluations)
        } catch {
            // Pagination failures stay visually silent; a later bottom-near trigger retries.
        }
    }

    private func nextFirstPageRequestID() -> Int {
        firstPageRequestID += 1
        return firstPageRequestID
    }
}

extension Array where Element == LectureEvaluation {
    fileprivate func removingDuplicateIDs() -> [LectureEvaluation] {
        var seenIDs = Set<EvaluationID>()
        return filter { seenIDs.insert($0.id).inserted }
    }
}
