//
//  EvaluationHomeViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Observation

@MainActor
@Observable
final class EvaluationHomeViewModel {
    var homeState: LoadState<EvaluationHomeContent> = .loading
    var path: [EvaluationDestination] = []

    @ObservationIgnored
    private let useCase: EvaluationHomeUseCase

    init() {
        @Dependency(\.evaluationRepository) var evaluationRepository
        self.useCase = EvaluationHomeUseCase(repository: evaluationRepository)
    }

    func load() async throws {
        homeState = .loading
        let data = try await useCase.loadHome()
        homeState = .loaded(data)
    }

    func refresh() async throws {
        let data = try await useCase.loadHome()
        homeState = .loaded(data)
    }

    func selectSort(_ sort: EvaluationSort) async throws {
        guard case .loaded(let previousState) = homeState, previousState.selectedSort != sort else { return }

        let requestedSort = sort
        homeState = .loaded(
            .init(
                selectedSort: sort,
                availableSorts: previousState.availableSorts,
                mainFeed: previousState.mainFeed,
                takenLectureFeed: previousState.takenLectureFeed
            )
        )

        do {
            let page = try await useCase.loadEvaluations(sort: sort, cursor: nil)
            guard case .loaded(let currentState) = homeState,
                currentState.selectedSort == requestedSort
            else { return }
            homeState = .loaded(
                .init(
                    selectedSort: requestedSort,
                    availableSorts: currentState.availableSorts,
                    mainFeed: EvaluationFeedContent(
                        evaluations: page.evaluations,
                        cursor: page.cursor,
                        canLoadMore: !page.isLast
                    ),
                    takenLectureFeed: currentState.takenLectureFeed
                )
            )
        } catch {
            guard case .loaded(let currentState) = homeState,
                currentState.selectedSort == requestedSort
            else { return }
            homeState = .loaded(previousState)
            throw error
        }
    }

    func openSearch() {
        path.append(.search)
    }

    func openFilter() {
        path.append(.filter)
    }

    func openEvaluationDetail(_ id: EvaluationID) {
        path.append(.evaluationDetail(id))
    }

    func openLectureDetail(_ id: EvaluationLectureID) {
        path.append(.lectureDetail(id))
    }

    func openWriteEvaluation(_ id: EvaluationLectureID) {
        path.append(.writeEvaluation(id))
    }

    func openMyEvaluations() {
        path.append(.myEvaluations)
    }

    func openAllEvaluations(sort: EvaluationSort.Kind) {
        path.append(.allEvaluations(sort: sort))
    }
}

enum LoadState<Value: Equatable & Sendable>: Equatable, Sendable {
    case loading
    case loaded(Value)
}
