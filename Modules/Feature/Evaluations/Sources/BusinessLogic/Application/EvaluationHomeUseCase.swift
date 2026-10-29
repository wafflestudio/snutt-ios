//
//  EvaluationHomeUseCase.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import TimetableInterface

struct EvaluationHomeUseCase: Sendable {
    private let repository: any EvaluationRepository

    init(repository: any EvaluationRepository) {
        self.repository = repository
    }

    func loadHome() async throws -> EvaluationHomeContent {
        let sorts = try await repository.fetchMainSorts()
        let recommendedSort = try requiredSort(.recommended, in: sorts, displayName: "추천")
        let latestSort = try requiredSort(.latest, in: sorts, displayName: "최신")

        async let mainPage = loadEvaluations(sort: recommendedSort, cursor: nil)
        async let takenLectures = loadTakenLectures()

        let loadedMainPage = try await mainPage
        let loadedTakenLectures = try await takenLectures
        let takenLectureFeed = takenLectureFeed(lectures: loadedTakenLectures)

        return EvaluationHomeContent(
            selectedSort: recommendedSort,
            availableSorts: [recommendedSort, latestSort],
            mainFeed: EvaluationFeedContent(
                evaluations: loadedMainPage.evaluations,
                cursor: loadedMainPage.cursor,
                canLoadMore: !loadedMainPage.isLast
            ),
            takenLectureFeed: takenLectureFeed
        )
    }

    func loadEvaluations(sort: EvaluationSort, cursor: String?) async throws -> EvaluationPage {
        try await repository.fetchEvaluations(sort: sort, cursor: cursor)
    }

    func loadTakenLectures() async throws -> [TakenLectureSummary] {
        try await repository.fetchTakenLectures()
    }

    private func requiredSort(
        _ kind: EvaluationSort.Kind,
        in sorts: [EvaluationSort],
        displayName: String
    ) throws -> EvaluationSort {
        guard let sort = sorts.first(where: { $0.kind == kind }) else {
            throw EvaluationError.missingRequiredSort(displayName)
        }
        return sort
    }

    private func takenLectureFeed(lectures: [TakenLectureSummary]) -> TakenLectureFeedContent? {
        guard let representativeQuarter = lectures.map(\.takenQuarter).max() else {
            return nil
        }
        return TakenLectureFeedContent(
            takenQuarter: representativeQuarter,
            lectures: lectures
        )
    }
}
