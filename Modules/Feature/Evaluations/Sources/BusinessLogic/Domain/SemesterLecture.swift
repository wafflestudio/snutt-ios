//
//  SemesterLecture.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import TimetableInterface

/// A lecture offered in a specific semester, the unit an evaluation is written against.
struct SemesterLecture: Equatable, Identifiable, Sendable {
    let id: SemesterLectureID
    let quarter: Quarter
    let hasMyEvaluation: Bool
}

/// The lecture being evaluated and the semesters it was offered in.
struct EvaluationWriteTarget: Equatable, Sendable {
    let lecture: EvaluationLectureBrief
    /// Offered semesters, most recent first.
    let semesterLectures: [SemesterLecture]

    var writableSemesterLectures: [SemesterLecture] {
        semesterLectures.filter { !$0.hasMyEvaluation }
    }
}
