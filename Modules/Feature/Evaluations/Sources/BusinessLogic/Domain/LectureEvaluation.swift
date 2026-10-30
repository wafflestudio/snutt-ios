//
//  LectureEvaluation.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import TimetableInterface

/// A single lecture evaluation written by a user.
struct LectureEvaluation: Equatable, Identifiable, Sendable {
    let id: EvaluationID
    let lectureID: EvaluationLectureID
    let rating: Double
    /// Detailed scores. Evaluations migrated from the legacy service may not have them.
    let scores: EvaluationScores?
    let content: String
    let quarter: Quarter
    var like: EvaluationLike
    let permissions: Permissions

    /// Actions the current user may take on an evaluation.
    struct Permissions: OptionSet, Equatable, Sendable {
        let rawValue: Int

        static let modify = Permissions(rawValue: 1 << 0)
        static let report = Permissions(rawValue: 1 << 1)
    }
}

/// The like count of an evaluation and whether the current user liked it.
struct EvaluationLike: Equatable, Sendable {
    let count: Int
    let isLiked: Bool

    func toggled() -> EvaluationLike {
        EvaluationLike(count: max(0, count + (isLiked ? -1 : 1)), isLiked: !isLiked)
    }
}

/// An evaluation paired with the lecture it belongs to, used by feeds that mix lectures.
struct EvaluationWithLecture: Equatable, Identifiable, Sendable {
    var evaluation: LectureEvaluation
    let lecture: EvaluationLectureBrief

    var id: EvaluationID { evaluation.id }
}
