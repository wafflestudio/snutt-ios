//
//  LiveDependencies.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation

enum EvaluationRepositoryKey: DependencyKey {
    static let liveValue: any EvaluationRepository = EvaluationAPIRepository()
    static let previewValue: any EvaluationRepository = EvaluationPreviewRepository()
}

enum EvaluationSearchFilterStoreKey: DependencyKey {
    static let liveValue: any EvaluationSearchFilterStore = EvaluationSearchFilterUserDefaultsStore()
    static let previewValue: any EvaluationSearchFilterStore = EvaluationSearchFilterUserDefaultsStore()
}

extension DependencyValues {
    var evaluationRepository: any EvaluationRepository {
        get { self[EvaluationRepositoryKey.self] }
        set { self[EvaluationRepositoryKey.self] = newValue }
    }

    var evaluationSearchFilterStore: any EvaluationSearchFilterStore {
        get { self[EvaluationSearchFilterStoreKey.self] }
        set { self[EvaluationSearchFilterStoreKey.self] = newValue }
    }
}

/// Serves ``EvaluationPreviewFixtures`` with a short delay so previews show their loading states.
struct EvaluationPreviewRepository: EvaluationRepository {
    private typealias Fixtures = EvaluationPreviewFixtures

    func fetchMainSorts() async throws -> [EvaluationSort] {
        try await simulateNetworkDelay()
        return Fixtures.sorts
    }

    func fetchEvaluations(sort: EvaluationSort, cursor: String?) async throws -> CursorPage<EvaluationWithLecture> {
        try await simulateNetworkDelay()
        let feed = sort.kind == .recommended ? Fixtures.feed : Fixtures.feed.reversed()
        return CursorPage(items: feed, nextCursor: nil)
    }

    func fetchTakenLectures() async throws -> [TakenLecture] {
        try await simulateNetworkDelay()
        return Fixtures.takenLectures
    }

    func fetchLectureSummary(lectureID: EvaluationLectureID) async throws -> LectureEvaluationSummary {
        try await simulateNetworkDelay()
        return Fixtures.summary
    }

    func fetchLectureEvaluations(
        lectureID: EvaluationLectureID,
        cursor: String?
    ) async throws -> CursorPage<LectureEvaluation> {
        try await simulateNetworkDelay()
        return CursorPage(items: Fixtures.feed.map(\.evaluation), nextCursor: nil)
    }

    func fetchMyLectureEvaluations(lectureID: EvaluationLectureID) async throws -> [LectureEvaluation] {
        try await simulateNetworkDelay()
        return []
    }

    func fetchMyEvaluations(cursor: String?) async throws -> CursorPage<EvaluationWithLecture> {
        try await simulateNetworkDelay()
        return CursorPage(items: Fixtures.feed, nextCursor: nil)
    }

    func fetchSearchTagGroups() async throws -> [SearchTagGroup] {
        try await simulateNetworkDelay()
        return Fixtures.tagGroups
    }

    func searchLectures(query: LectureSearchQuery, page: Int) async throws -> LectureSearchPage {
        try await simulateNetworkDelay()
        return LectureSearchPage(results: Fixtures.searchResults, page: page, isLast: true)
    }

    func fetchWriteTarget(lectureID: EvaluationLectureID) async throws -> EvaluationWriteTarget {
        try await simulateNetworkDelay()
        return Fixtures.writeTarget
    }

    func createEvaluation(_ submission: EvaluationSubmission) async throws -> EvaluationID {
        try await simulateNetworkDelay()
        return EvaluationID(999)
    }

    func updateEvaluation(id: EvaluationID, _ submission: EvaluationSubmission) async throws {
        try await simulateNetworkDelay()
    }

    func deleteEvaluation(id: EvaluationID) async throws {}
    func setLiked(_ isLiked: Bool, evaluationID: EvaluationID) async throws {}
    func reportEvaluation(id: EvaluationID, reason: String) async throws {}

    private func simulateNetworkDelay() async throws {
        try await Task.sleep(for: .milliseconds(600))
    }
}
