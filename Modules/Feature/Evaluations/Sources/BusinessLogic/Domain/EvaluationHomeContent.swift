//
//  EvaluationHomeContent.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import TimetableInterface

/// Everything the evaluation home screen renders.
struct EvaluationHomeContent: Equatable, Sendable {
    var selectedSort: EvaluationSort
    let availableSorts: [EvaluationSort]
    var mainFeed: [EvaluationWithLecture]
    var takenLectureGroups: [TakenLectureGroup]
}

/// Lectures the current user took in one semester.
struct TakenLectureGroup: Equatable, Identifiable, Sendable {
    let quarter: Quarter
    var lectures: [TakenLecture]

    var id: Quarter { quarter }
}

/// A lecture that the current user has taken and can evaluate.
struct TakenLecture: Equatable, Identifiable, Sendable {
    let info: EvaluationLectureInfo
    let takenQuarter: Quarter
    /// The lecture's average rating, or `nil` when nobody has evaluated it yet.
    var averageRating: Double?
    /// Evaluations the current user wrote for this lecture.
    var myEvaluations: [LectureEvaluation]

    var id: EvaluationLectureID { info.id }
}
