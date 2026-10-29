//
//  LectureEvaluation.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

/// A single lecture evaluation written by a user.
struct LectureEvaluation: Equatable, Identifiable, Sendable {
    let id: EvaluationID
    let lecture: EvaluationLectureBrief
    let rating: Double
    let content: String
    let year: Int
    let semester: Int
    let likeCount: Int
    let isLiked: Bool
    let isReportable: Bool
    let scores: [LectureEvaluationScore]

    init(
        id: EvaluationID,
        lecture: EvaluationLectureBrief,
        rating: Double,
        content: String,
        year: Int,
        semester: Int,
        likeCount: Int,
        isLiked: Bool,
        isReportable: Bool,
        scores: [LectureEvaluationScore] = []
    ) {
        self.id = id
        self.lecture = lecture
        self.rating = rating
        self.content = content
        self.year = year
        self.semester = semester
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.isReportable = isReportable
        self.scores = scores
    }
}

/// Client-only score labels used by the native evaluation UI while the list API is still being developed.
struct LectureEvaluationScore: Equatable, Identifiable, Sendable {
    let title: String
    let value: Double

    var id: String { title }

    init(title: String, value: Double) {
        self.title = title
        self.value = value
    }
}
