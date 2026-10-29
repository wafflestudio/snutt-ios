//
//  EvaluationLectureDetailContent.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation

struct EvaluationLectureDetailContent: Equatable, Sendable {
    let lecture: EvaluationLectureBrief
    let department: String
    let classification: String
    let credit: Int
    let averageRating: Double
    let reviewCount: Int
    let scoreSummary: [LectureEvaluationScore]
    let evaluations: [LectureEvaluation]

    init(
        lecture: EvaluationLectureBrief,
        department: String,
        classification: String,
        credit: Int,
        averageRating: Double,
        reviewCount: Int,
        scoreSummary: [LectureEvaluationScore],
        evaluations: [LectureEvaluation]
    ) {
        self.lecture = lecture
        self.department = department
        self.classification = classification
        self.credit = credit
        self.averageRating = averageRating
        self.reviewCount = reviewCount
        self.scoreSummary = scoreSummary
        self.evaluations = evaluations
    }

    init(takenLecture: TakenLectureSummary) {
        self.init(
            lecture: takenLecture.lecture,
            department: takenLecture.department ?? "학과",
            classification: takenLecture.classification ?? "교과구분",
            credit: takenLecture.credit ?? 0,
            averageRating: takenLecture.averageRating ?? takenLecture.evaluations.averageRating,
            reviewCount: takenLecture.evaluations.count,
            scoreSummary: takenLecture.evaluations.averageScores,
            evaluations: takenLecture.evaluations
        )
    }

    static func empty(lectureID: EvaluationLectureID) -> Self {
        Self(
            lecture: EvaluationLectureBrief(
                id: lectureID,
                title: "강의 정보",
                instructor: nil
            ),
            department: "학과",
            classification: "교과구분",
            credit: 0,
            averageRating: 0,
            reviewCount: 0,
            scoreSummary: [],
            evaluations: []
        )
    }

    var lectureMetaText: String {
        "\(department) · \(classification) · \(credit)학점"
    }
}

extension [LectureEvaluation] {
    fileprivate var averageRating: Double {
        guard !isEmpty else { return 0 }
        return map(\.rating).reduce(0, +) / Double(count)
    }

    fileprivate var averageScores: [LectureEvaluationScore] {
        let titles = flatMap(\.scores).map(\.title).uniqued()
        return titles.compactMap { title in
            let values = flatMap(\.scores)
                .filter { $0.title == title }
                .map(\.value)
            guard !values.isEmpty else { return nil }
            return LectureEvaluationScore(
                title: title,
                value: values.reduce(0, +) / Double(values.count)
            )
        }
    }
}

extension [String] {
    fileprivate func uniqued() -> [String] {
        reduce(into: []) { result, value in
            guard !result.contains(value) else { return }
            result.append(value)
        }
    }
}
