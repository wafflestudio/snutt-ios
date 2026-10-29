//
//  EvaluationPreviewFixtures.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import TimetableInterface

enum EvaluationPreviewFixtures {
    static let recommendedSort = EvaluationSort(id: 1, kind: .recommended)
    static let latestSort = EvaluationSort(id: 2, kind: .latest)
    static let sorts = [recommendedSort, latestSort]
    static let scoreSet = [
        LectureEvaluationScore(title: "성적", value: 2.0),
        LectureEvaluationScore(title: "유익함", value: 5.0),
        LectureEvaluationScore(title: "강의력", value: 4.5),
        LectureEvaluationScore(title: "널널함", value: 3.5),
    ]

    static let homeContent = EvaluationHomeContent(
        selectedSort: recommendedSort,
        availableSorts: sorts,
        mainFeed: EvaluationFeedContent(
            evaluations: evaluations,
            cursor: "preview-next",
            canLoadMore: true
        ),
        takenLectureFeed: takenLectureFeed
    )

    static let evaluations: [LectureEvaluation] = [
        lectureEvaluation(
            id: 1,
            lectureID: 101,
            title: "컴퓨터의 개념 및 실습",
            instructor: "김민석",
            rating: 4.5,
            content: "매주 실습으로 개념을 확인해서 따라가기 좋습니다. 코딩 경험이 적어도 과제 피드백을 받으며 익숙해질 수 있습니다.",
            likeCount: 12,
            isLiked: true
        ),
        lectureEvaluation(
            id: 2,
            lectureID: 102,
            title: "자료구조",
            instructor: "이서현",
            rating: 4.0,
            content: "스택, 트리, 그래프를 구현 과제로 다룹니다. 시험은 강의 노트 중심이라 복습을 꾸준히 하면 안정적입니다.",
            likeCount: 7,
            isLiked: false
        ),
        lectureEvaluation(
            id: 3,
            lectureID: 103,
            title: "인공지능의 이해",
            instructor: "박상철",
            rating: 4.8,
            content: "모델 원리를 깊게 파기보다 활용 사례와 한계를 폭넓게 봅니다. 발표 토론이 많아 수업 참여가 중요합니다.",
            likeCount: 24,
            isLiked: true
        ),
    ]

    static let takenLectureFeed = TakenLectureFeedContent(
        takenQuarter: Quarter(year: 2025, semester: .second),
        lectures: [
            takenLecture(
                lectureID: 201,
                title: "편집디자인",
                instructor: "김민지",
                averageRating: 4.6,
                evaluations: [
                    lectureEvaluation(
                        id: 21,
                        lectureID: 201,
                        title: "편집디자인",
                        instructor: "김민지",
                        rating: 4.0,
                        content: "매주 작업물을 가져가면 피드백이 아주 구체적으로 돌아옵니다. 편집의 기준을 잡고 싶은 학생에게 잘 맞는 수업입니다.",
                        likeCount: 12,
                        isLiked: false,
                        scores: scoreSet
                    )
                ]
            ),
            takenLecture(
                lectureID: 202,
                title: "죽음의 과학적 이해",
                instructor: "정세윤",
                averageRating: nil,
                evaluations: []
            ),
            takenLecture(
                lectureID: 203,
                title: "모빌리티디자인프로젝트",
                instructor: "이도현",
                averageRating: 4.2,
                evaluations: [
                    lectureEvaluation(
                        id: 23,
                        lectureID: 203,
                        title: "모빌리티디자인프로젝트",
                        instructor: "이도현",
                        rating: 4.5,
                        content: "문제 정의부터 프로토타입 발표까지 한 학기 동안 길게 이어집니다. 팀 프로젝트 비중이 커서 일정 관리는 필요하지만 결과물이 남습니다.",
                        likeCount: 12,
                        isLiked: false,
                        scores: scoreSet
                    )
                ]
            ),
        ]
    )

    static var placeholderFeed: EvaluationFeedContent {
        EvaluationFeedContent(
            evaluations: [
                lectureEvaluation(
                    id: -1,
                    lectureID: -101,
                    title: "컴퓨터의 개념 및 실습",
                    instructor: "김교수",
                    rating: 4.5,
                    content: "과제가 실습 위주라 시간이 조금 걸리지만 수업 내용을 이해하는 데 도움이 됩니다.",
                    likeCount: 12,
                    isLiked: true,
                    scores: scoreSet
                ),
                lectureEvaluation(
                    id: -2,
                    lectureID: -102,
                    title: "자료구조와 알고리즘",
                    instructor: "이교수",
                    rating: 4.0,
                    content: "수업 자료가 잘 정리되어 있고 예제가 충분해 따라가기 좋습니다.",
                    likeCount: 8,
                    isLiked: false,
                    scores: scoreSet
                ),
                lectureEvaluation(
                    id: -3,
                    lectureID: -103,
                    title: "인공지능의 이해",
                    instructor: "박교수",
                    rating: 4.8,
                    content: "프로젝트 중심으로 진행되어 실제 적용 경험을 쌓을 수 있습니다.",
                    likeCount: 20,
                    isLiked: true,
                    scores: scoreSet
                ),
            ],
            cursor: nil,
            canLoadMore: false
        )
    }

    static var placeholderTakenLectureFeed: TakenLectureFeedContent {
        TakenLectureFeedContent(
            takenQuarter: Quarter(year: 2025, semester: .second),
            lectures: [
                takenLecture(
                    lectureID: -201,
                    title: "편집디자인",
                    instructor: "김민지",
                    averageRating: 4.6,
                    evaluations: [
                        lectureEvaluation(
                            id: -21,
                            lectureID: -201,
                            title: "편집디자인",
                            instructor: "김민지",
                            rating: 4.0,
                            content: "매주 작업물을 가져가면 피드백이 아주 구체적으로 돌아옵니다.",
                            likeCount: 12,
                            isLiked: false,
                            scores: scoreSet
                        )
                    ]
                ),
                takenLecture(
                    lectureID: -202,
                    title: "죽음의 과학적 이해",
                    instructor: "정세윤",
                    averageRating: nil,
                    evaluations: []
                ),
            ]
        )
    }

    private static func lectureEvaluation(
        id: EvaluationID,
        lectureID: EvaluationLectureID,
        title: String,
        instructor: String,
        rating: Double,
        content: String,
        likeCount: Int,
        isLiked: Bool,
        scores: [LectureEvaluationScore] = []
    ) -> LectureEvaluation {
        LectureEvaluation(
            id: id,
            lecture: EvaluationLectureBrief(
                id: lectureID,
                title: title,
                instructor: instructor
            ),
            rating: rating,
            content: content,
            year: 2025,
            semester: 2,
            likeCount: likeCount,
            isLiked: isLiked,
            isReportable: true,
            scores: scores
        )
    }

    private static func takenLecture(
        lectureID: EvaluationLectureID,
        title: String,
        instructor: String,
        averageRating: Double? = nil,
        evaluations: [LectureEvaluation] = []
    ) -> TakenLectureSummary {
        TakenLectureSummary(
            lecture: EvaluationLectureBrief(
                id: lectureID,
                title: title,
                instructor: instructor
            ),
            department: "컴퓨터공학부",
            courseNumber: "M1522.000100",
            credit: 3,
            academicYear: "3",
            classification: "전공선택",
            takenQuarter: Quarter(year: 2025, semester: .second),
            averageRating: averageRating,
            evaluations: evaluations
        )
    }
}

extension EvaluationSort {
    static var placeholderRecommended: Self {
        EvaluationPreviewFixtures.recommendedSort
    }

    static var placeholderLatest: Self {
        EvaluationPreviewFixtures.latestSort
    }
}

extension EvaluationFeedContent {
    static var placeholder: Self {
        EvaluationPreviewFixtures.placeholderFeed
    }
}

extension TakenLectureFeedContent {
    static var placeholder: Self {
        EvaluationPreviewFixtures.placeholderTakenLectureFeed
    }
}
