//
//  EvaluationLectureDetailPreviewHelper.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

enum EvaluationLectureDetailPreviewHelper {
    static let detail = EvaluationLectureDetailContent(
        lecture: EvaluationLectureBrief(
            id: EvaluationLectureID(101),
            title: "인공지능 신뢰성",
            instructor: "박상철"
        ),
        department: "협동과정 인공지능전공",
        classification: "전선",
        credit: 3,
        averageRating: 3.0,
        reviewCount: 3,
        scoreSummary: [
            LectureEvaluationScore(title: "성적", value: 2.0),
            LectureEvaluationScore(title: "유익함", value: 4.5),
            LectureEvaluationScore(title: "강의력", value: 3.5),
            LectureEvaluationScore(title: "널널함", value: 5.0),
        ],
        evaluations: evaluations
    )

    private static let evaluations: [LectureEvaluation] = [1, 2].map { index in
        LectureEvaluation(
            id: EvaluationID(index),
            lecture: EvaluationLectureBrief(
                id: EvaluationLectureID(101),
                title: "인공지능 신뢰성",
                instructor: "박상철"
            ),
            rating: 3.0,
            content: "강의평 내용을 입력하세요. 강의평 내용을 입력하세요. 강의평 내용을 입력하세요. 강의평 내용을 입력하세요. 강의평 강의평 내용을 입력하세요.",
            year: 2025,
            semester: 2,
            likeCount: 12,
            isLiked: false,
            isReportable: true,
            scores: [
                LectureEvaluationScore(title: "성적", value: 2.0),
                LectureEvaluationScore(title: "유익함", value: 5.0),
                LectureEvaluationScore(title: "강의력", value: 4.5),
                LectureEvaluationScore(title: "널널함", value: 3.5),
            ]
        )
    }
}
