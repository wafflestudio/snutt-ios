//
//  TakenLectureSummary.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import TimetableInterface

/// A lecture that the current user has taken and can evaluate.
struct TakenLectureSummary: Equatable, Identifiable, Sendable {
    var id: EvaluationLectureID { lecture.id }
    let lecture: EvaluationLectureBrief
    let department: String?
    let courseNumber: String?
    let credit: Int?
    let academicYear: String?
    let classification: String?
    let takenQuarter: Quarter
    let averageRating: Double?
    let evaluations: [LectureEvaluation]
    let canWriteEvaluation: Bool

    init(
        lecture: EvaluationLectureBrief,
        department: String?,
        courseNumber: String?,
        credit: Int?,
        academicYear: String?,
        classification: String?,
        takenQuarter: Quarter,
        averageRating: Double? = nil,
        evaluations: [LectureEvaluation] = [],
        canWriteEvaluation: Bool = true
    ) {
        self.lecture = lecture
        self.department = department
        self.courseNumber = courseNumber
        self.credit = credit
        self.academicYear = academicYear
        self.classification = classification
        self.takenQuarter = takenQuarter
        self.averageRating = averageRating
        self.evaluations = evaluations
        self.canWriteEvaluation = canWriteEvaluation
    }
}
