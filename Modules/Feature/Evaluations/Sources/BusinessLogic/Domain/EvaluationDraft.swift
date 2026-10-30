//
//  EvaluationDraft.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation

/// The in-progress state of the evaluation form.
struct EvaluationDraft: Equatable, Sendable {
    static let minimumContentLength = 20

    var semesterLectureID: SemesterLectureID?
    var rating: Double?
    var scores: [EvaluationCriterion: Double] = [:]
    var content = ""

    var contentLength: Int {
        content.trimmingCharacters(in: .whitespacesAndNewlines).count
    }

    var meetsMinimumContentLength: Bool {
        contentLength >= Self.minimumContentLength
    }

    /// A validated request, or `nil` while any required field is missing.
    var submission: EvaluationSubmission? {
        guard let semesterLectureID,
            let rating,
            let gradeSatisfaction = scores[.gradeSatisfaction],
            let teachingSkill = scores[.teachingSkill],
            let gains = scores[.gains],
            let lifeBalance = scores[.lifeBalance],
            meetsMinimumContentLength
        else { return nil }
        return EvaluationSubmission(
            semesterLectureID: semesterLectureID,
            rating: rating,
            scores: EvaluationScores(
                gradeSatisfaction: gradeSatisfaction,
                teachingSkill: teachingSkill,
                gains: gains,
                lifeBalance: lifeBalance
            ),
            content: content.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}

/// A complete evaluation ready to be sent to the server.
struct EvaluationSubmission: Equatable, Sendable {
    let semesterLectureID: SemesterLectureID
    let rating: Double
    let scores: EvaluationScores
    let content: String
}
