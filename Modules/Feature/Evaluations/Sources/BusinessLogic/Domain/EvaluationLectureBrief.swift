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

    init(id: EvaluationLectureID, title: String, instructor: String?) {
        self.id = id
        self.title = title
        self.instructor = instructor
    }
}
