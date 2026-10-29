//
//  EvaluationRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

/// A data access contract for the native evaluation flow.
protocol EvaluationRepository: Sendable {
    func fetchMainSorts() async throws -> [EvaluationSort]
    func fetchEvaluations(sort: EvaluationSort, cursor: String?) async throws -> EvaluationPage
    func fetchTakenLectures() async throws -> [TakenLectureSummary]
}

/// A page of lecture evaluations returned by the evaluation repository.
struct EvaluationPage: Equatable, Sendable {
    let evaluations: [LectureEvaluation]
    let cursor: String?
    let isLast: Bool

    init(evaluations: [LectureEvaluation], cursor: String?, isLast: Bool) {
        self.evaluations = evaluations
        self.cursor = cursor
        self.isLast = isLast
    }
}
