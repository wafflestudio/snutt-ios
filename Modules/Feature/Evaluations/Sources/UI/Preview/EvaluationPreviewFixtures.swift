//
//  EvaluationPreviewFixtures.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import TimetableInterface

/// Sample data for previews and for the redacted skeletons shown while content loads.
enum EvaluationPreviewFixtures {
    static let sorts = [
        EvaluationSort(id: 2, kind: .recommended),
        EvaluationSort(id: 1, kind: .latest),
    ]

    static let feed: [EvaluationWithLecture] = [
        feedItem(
            id: 101,
            lecture: lecture(id: 1101, title: "인공지능 신뢰성", instructor: "박상철"),
            rating: 4.0,
            content: "논문을 읽고 모델의 실패 사례를 토론하는 시간이 많습니다. 수식보다 사례 중심이라 신뢰성 이슈를 처음 접해도 따라갈 수 있습니다.",
            likeCount: 18
        ),
        feedItem(
            id: 102,
            lecture: lecture(id: 1102, title: "모빌리티디자인프로젝트", instructor: "이도현"),
            rating: 4.5,
            content: "사용자 리서치와 프로토타입 제작이 빠르게 반복됩니다. 팀원과 자주 만나야 하지만 포트폴리오에 넣을 만한 결과물이 나옵니다.",
            likeCount: 24,
            isLiked: true
        ),
        feedItem(
            id: 103,
            lecture: lecture(id: 1103, title: "디자인과 AI", instructor: "한서연"),
            rating: 3.5,
            content: "생성형 AI 도구를 실제 디자인 프로세스에 붙여보는 과제가 많습니다. 툴 사용 경험보다 결과를 설명하는 논리가 중요합니다.",
            likeCount: 9
        ),
    ]

    static let takenLectures: [TakenLecture] = [
        TakenLecture(
            info: lectureInfo(id: 201, title: "편집디자인", instructor: "김민지"),
            takenQuarter: Quarter(year: 2025, semester: .second),
            averageRating: 4.6,
            myEvaluations: [
                evaluation(
                    id: 301,
                    lectureID: 201,
                    rating: 4.0,
                    content: "매주 작업물을 가져가면 피드백이 아주 구체적으로 돌아옵니다. 편집의 기준을 잡고 싶은 학생에게 잘 맞는 수업입니다.",
                    likeCount: 12
                )
            ]
        ),
        TakenLecture(
            info: lectureInfo(id: 202, title: "죽음의 과학적 이해", instructor: "정세윤"),
            takenQuarter: Quarter(year: 2025, semester: .second),
            averageRating: nil,
            myEvaluations: []
        ),
    ]

    static var takenLectureGroups: [TakenLectureGroup] {
        [TakenLectureGroup(quarter: Quarter(year: 2025, semester: .second), lectures: takenLectures)]
    }

    static var homeContent: EvaluationHomeContent {
        EvaluationHomeContent(
            selectedSort: sorts[0],
            availableSorts: sorts,
            mainFeed: feed,
            takenLectureGroups: takenLectureGroups
        )
    }

    static let summary = LectureEvaluationSummary(
        info: lectureInfo(id: 1101, title: "인공지능 신뢰성", instructor: "박상철"),
        averageRating: 3.8,
        averageScores: scores,
        evaluationCount: 3
    )

    static let searchResults: [LectureSearchResult] = [
        LectureSearchResult(
            info: lectureInfo(id: 1101, title: "인공지능 신뢰성", instructor: "박상철"),
            averageRating: 3.0,
            evaluationCount: 3
        ),
        LectureSearchResult(
            info: lectureInfo(id: 1104, title: "인공지능과 생활", instructor: "최유진"),
            averageRating: nil,
            evaluationCount: 0
        ),
        LectureSearchResult(
            info: lectureInfo(id: 1105, title: "인공지능", instructor: "장병탁"),
            averageRating: 4.6,
            evaluationCount: 15
        ),
    ]

    static let tagGroups: [SearchTagGroup] = [
        SearchTagGroup(
            id: 1,
            name: "학년",
            tags: ["1학년", "2학년", "3학년", "4학년"].enumerated().map { tag(id: 6 + $0.offset, name: $0.element) }
        ),
        SearchTagGroup(
            id: 2,
            name: "구분",
            tags: ["교양", "전필", "전선", "일선"].enumerated().map { tag(id: 16 + $0.offset, name: $0.element) }
        ),
        SearchTagGroup(
            id: 3,
            name: "학점",
            tags: ["1학점", "2학점", "3학점", "4학점"].enumerated().map { tag(id: 23 + $0.offset, name: $0.element) }
        ),
        SearchTagGroup(
            id: 4,
            name: "학과",
            tags: ["AI융합교육학과", "건축학과", "간호학과", "건설환경공학부", "디자인과", "컴퓨터공학부"]
                .enumerated().map { tag(id: 30 + $0.offset, name: $0.element) }
        ),
    ]

    static let writeTarget = EvaluationWriteTarget(
        lecture: lecture(id: 1101, title: "인공지능 신뢰성", instructor: "박상철"),
        semesterLectures: [
            SemesterLecture(id: 3, quarter: Quarter(year: 2026, semester: .first), hasMyEvaluation: false),
            SemesterLecture(id: 2, quarter: Quarter(year: 2025, semester: .second), hasMyEvaluation: false),
            SemesterLecture(id: 1, quarter: Quarter(year: 2025, semester: .first), hasMyEvaluation: true),
        ]
    )

    static let scores = EvaluationScores(gradeSatisfaction: 2.0, teachingSkill: 4.5, gains: 5.0, lifeBalance: 3.5)

    // MARK: Builders

    private static func lecture(id: EvaluationLectureID, title: String, instructor: String) -> EvaluationLectureBrief {
        EvaluationLectureBrief(id: id, title: title, instructor: instructor)
    }

    private static func lectureInfo(id: EvaluationLectureID, title: String, instructor: String) -> EvaluationLectureInfo
    {
        EvaluationLectureInfo(
            brief: lecture(id: id, title: title, instructor: instructor),
            department: "컴퓨터공학부",
            academicYear: "3학년",
            classification: "전선",
            credit: 3
        )
    }

    private static func tag(id: Int, name: String) -> SearchTag {
        SearchTag(id: SearchTagID(Int64(id)), name: name)
    }

    private static func evaluation(
        id: EvaluationID,
        lectureID: EvaluationLectureID,
        rating: Double,
        content: String,
        likeCount: Int,
        isLiked: Bool = false
    ) -> LectureEvaluation {
        LectureEvaluation(
            id: id,
            lectureID: lectureID,
            rating: rating,
            scores: scores,
            content: content,
            quarter: Quarter(year: 2025, semester: .second),
            like: EvaluationLike(count: likeCount, isLiked: isLiked),
            permissions: .report
        )
    }

    private static func feedItem(
        id: EvaluationID,
        lecture: EvaluationLectureBrief,
        rating: Double,
        content: String,
        likeCount: Int,
        isLiked: Bool = false
    ) -> EvaluationWithLecture {
        EvaluationWithLecture(
            evaluation: evaluation(
                id: id,
                lectureID: lecture.id,
                rating: rating,
                content: content,
                likeCount: likeCount,
                isLiked: isLiked
            ),
            lecture: lecture
        )
    }
}
