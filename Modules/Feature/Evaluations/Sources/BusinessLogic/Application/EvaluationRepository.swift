//
//  EvaluationRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

/// A data access contract for the native evaluation flow.
protocol EvaluationRepository: Sendable {
    func fetchMainSorts() async throws -> [EvaluationSort]
    func fetchEvaluations(sort: EvaluationSort, cursor: String?) async throws -> CursorPage<EvaluationWithLecture>
    func fetchTakenLectures() async throws -> [TakenLecture]

    func fetchLectureSummary(lectureID: EvaluationLectureID) async throws -> LectureEvaluationSummary
    func fetchLectureEvaluations(
        lectureID: EvaluationLectureID,
        cursor: String?
    ) async throws -> CursorPage<LectureEvaluation>
    func fetchMyLectureEvaluations(lectureID: EvaluationLectureID) async throws -> [LectureEvaluation]
    func fetchMyEvaluations(cursor: String?) async throws -> CursorPage<EvaluationWithLecture>

    func fetchSearchTagGroups() async throws -> [SearchTagGroup]
    func searchLectures(query: LectureSearchQuery, page: Int) async throws -> LectureSearchPage

    func fetchWriteTarget(lectureID: EvaluationLectureID) async throws -> EvaluationWriteTarget
    func createEvaluation(_ submission: EvaluationSubmission) async throws -> EvaluationID
    func updateEvaluation(id: EvaluationID, _ submission: EvaluationSubmission) async throws
    func deleteEvaluation(id: EvaluationID) async throws
    func setLiked(_ isLiked: Bool, evaluationID: EvaluationID) async throws
    func reportEvaluation(id: EvaluationID, reason: String) async throws
}

/// Persists the lecture search filters so they survive app launches.
protocol EvaluationSearchFilterStore: Sendable {
    func loadTags() -> [SearchTag]
    func saveTags(_ tags: [SearchTag])
}
