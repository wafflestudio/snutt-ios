//
//  LectureEvaluationSummary.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

/// Aggregated evaluation information for a single lecture.
struct LectureEvaluationSummary: Equatable, Sendable {
    let info: EvaluationLectureInfo
    let averageRating: Double?
    let averageScores: EvaluationScores?
    let evaluationCount: Int
}
