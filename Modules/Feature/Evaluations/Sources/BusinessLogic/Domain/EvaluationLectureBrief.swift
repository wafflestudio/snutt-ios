//
//  EvaluationLectureBrief.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

/// A lightweight lecture reference used inside evaluation screens.
struct EvaluationLectureBrief: Equatable, Identifiable, Sendable {
    let id: EvaluationLectureID
    let title: String
    let instructor: String?
}

/// Lecture details shown alongside evaluations, such as the department and credit.
struct EvaluationLectureInfo: Equatable, Identifiable, Sendable {
    let brief: EvaluationLectureBrief
    let department: String?
    let academicYear: String?
    let classification: String?
    let credit: Int?

    var id: EvaluationLectureID { brief.id }
}
