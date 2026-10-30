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
        guard let recommendedSort = sorts.first(where: { $0.kind == .recommended }),
            let latestSort = sorts.first(where: { $0.kind == .latest })
        else {
            throw EvaluationError.missingRequiredSort
        }

        async let mainPage = repository.fetchEvaluations(sort: recommendedSort, cursor: nil)
        async let takenLectureGroups = loadTakenLectureGroups()

        return try await EvaluationHomeContent(
            selectedSort: recommendedSort,
            availableSorts: [recommendedSort, latestSort],
            mainFeed: mainPage.items,
            takenLectureGroups: takenLectureGroups
        )
    }

    /// Loads taken lectures grouped by semester, most recent first, each enriched with its
    /// average rating and the current user's evaluations.
    func loadTakenLectureGroups() async throws -> [TakenLectureGroup] {
        let lectures = try await repository.fetchTakenLectures()
        let enrichedLectures = await withTaskGroup(of: (Int, TakenLecture).self) { group in
            for (index, lecture) in lectures.enumerated() {
                group.addTask {
                    (index, await enriched(lecture))
                }
            }
            var results = lectures
            for await (index, lecture) in group {
                results[index] = lecture
            }
            return results
        }
        return Dictionary(grouping: enrichedLectures, by: \.takenQuarter)
            .map { TakenLectureGroup(quarter: $0.key, lectures: $0.value) }
            .sorted { $0.quarter > $1.quarter }
    }

    /// Enrichment is best-effort: a lecture still renders when its summary fails to load.
    private func enriched(_ lecture: TakenLecture) async -> TakenLecture {
        async let summary = try? repository.fetchLectureSummary(lectureID: lecture.id)
        async let myEvaluations = try? repository.fetchMyLectureEvaluations(lectureID: lecture.id)
        var lecture = lecture
        lecture.averageRating = await summary?.averageRating
        lecture.myEvaluations = await myEvaluations ?? []
        return lecture
    }
}
