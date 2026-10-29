//
//  LiveDependencies.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import TimetableInterface

enum EvaluationRepositoryKey: DependencyKey {
    #if DEBUG
    static let liveValue: any EvaluationRepository = EvaluationFakeRepository()
    #else
    static let liveValue: any EvaluationRepository = EvaluationAPIRepository()
    #endif
    static let previewValue: any EvaluationRepository = EvaluationFakeRepository()
}

extension DependencyValues {
    var evaluationRepository: any EvaluationRepository {
        get { self[EvaluationRepositoryKey.self] }
        set { self[EvaluationRepositoryKey.self] = newValue }
    }
}

struct EvaluationFakeRepository: EvaluationRepository {
    func fetchMainSorts() async throws -> [EvaluationSort] {
        try await simulateNetworkDelay()
        return [recommendedSort, latestSort]
    }

    func fetchEvaluations(sort: EvaluationSort, cursor: String?) async throws -> EvaluationPage {
        try await simulateNetworkDelay()
        switch sort.kind {
        case .recommended:
            return page(
                sortPrefix: "recommended",
                evaluations: recommendedEvaluations,
                cursor: cursor
            )
        case .latest:
            return page(
                sortPrefix: "latest",
                evaluations: latestEvaluations,
                cursor: cursor
            )
        }
    }

    func fetchTakenLectures() async throws -> [TakenLectureSummary] {
        try await simulateNetworkDelay()
        return [
            takenLecture(
                id: 201,
                title: "편집디자인",
                instructor: "김민지",
                takenQuarter: Quarter(year: 2025, semester: .second),
                averageRating: 4.6,
                evaluations: [
                    takenEvaluation(
                        id: 301,
                        lectureID: 201,
                        title: "편집디자인",
                        instructor: "김민지",
                        rating: 4.0,
                        content: "매주 작업물을 가져가면 피드백이 아주 구체적으로 돌아옵니다. 편집의 기준을 잡고 싶은 학생에게 잘 맞는 수업입니다.",
                        scores: [
                            LectureEvaluationScore(title: "성적", value: 3.5),
                            LectureEvaluationScore(title: "유익함", value: 5.0),
                            LectureEvaluationScore(title: "강의력", value: 4.5),
                            LectureEvaluationScore(title: "널널함", value: 2.5),
                        ]
                    )
                ]
            ),
            takenLecture(
                id: 202,
                title: "죽음의 과학적 이해",
                instructor: "정세윤",
                takenQuarter: Quarter(year: 2025, semester: .second),
                averageRating: nil,
                evaluations: []
            ),
            takenLecture(
                id: 203,
                title: "모빌리티디자인프로젝트",
                instructor: "이도현",
                takenQuarter: Quarter(year: 2025, semester: .second),
                averageRating: 4.2,
                evaluations: [
                    takenEvaluation(
                        id: 303,
                        lectureID: 203,
                        title: "모빌리티디자인프로젝트",
                        instructor: "이도현",
                        rating: 4.5,
                        content: "문제 정의부터 프로토타입 발표까지 한 학기 동안 길게 이어집니다. 팀 프로젝트 비중이 커서 일정 관리는 필요하지만 결과물이 남습니다.",
                        scores: [
                            LectureEvaluationScore(title: "성적", value: 4.0),
                            LectureEvaluationScore(title: "유익함", value: 4.5),
                            LectureEvaluationScore(title: "강의력", value: 4.0),
                            LectureEvaluationScore(title: "널널함", value: 2.0),
                        ]
                    )
                ]
            ),
        ]
    }

    private var recommendedSort: EvaluationSort {
        EvaluationSort(id: 1, kind: .recommended)
    }

    private var latestSort: EvaluationSort {
        EvaluationSort(id: 2, kind: .latest)
    }

    private var recommendedEvaluations: [LectureEvaluation] {
        [
            evaluation(
                id: 101,
                lectureID: 1101,
                title: "인공지능 신뢰성",
                instructor: "박상철",
                rating: 4.0,
                content: "논문을 읽고 모델의 실패 사례를 토론하는 시간이 많습니다. 수식보다 사례 중심이라 신뢰성 이슈를 처음 접해도 따라갈 수 있습니다.",
                likeCount: 18,
                isLiked: false
            ),
            evaluation(
                id: 102,
                lectureID: 1102,
                title: "모빌리티디자인프로젝트",
                instructor: "이도현",
                rating: 4.5,
                content: "사용자 리서치와 프로토타입 제작이 빠르게 반복됩니다. 팀원과 자주 만나야 하지만 포트폴리오에 넣을 만한 결과물이 나옵니다.",
                likeCount: 24,
                isLiked: false
            ),
            evaluation(
                id: 103,
                lectureID: 1103,
                title: "디자인과 AI",
                instructor: "한서연",
                rating: 3.5,
                content: "생성형 AI 도구를 실제 디자인 프로세스에 붙여보는 과제가 많습니다. 툴 사용 경험보다 결과를 설명하는 논리가 중요합니다.",
                likeCount: 9,
                isLiked: false
            ),
            evaluation(
                id: 104,
                lectureID: 1104,
                title: "서비스디자인",
                instructor: "최유진",
                rating: 4.0,
                content: "인터뷰 설계부터 여정 지도 작성까지 차근차근 다룹니다. 발표가 잦아 부담은 있지만 피드백이 실무적으로 도움이 됩니다.",
                likeCount: 15,
                isLiked: false
            ),
            evaluation(
                id: 105,
                lectureID: 1105,
                title: "사용자경험연구",
                instructor: "오지훈",
                rating: 4.5,
                content: "정량 설문과 정성 인터뷰를 모두 다룹니다. 과제는 촘촘하지만 연구 질문을 좁히는 법을 제대로 배울 수 있습니다.",
                likeCount: 31,
                isLiked: false
            ),
            evaluation(
                id: 106,
                lectureID: 1106,
                title: "브랜드디자인",
                instructor: "문가영",
                rating: 3.5,
                content: "브랜드 시스템을 한 번에 완성하기보다 매주 작은 산출물을 누적합니다. 크리틱 분위기가 엄격한 편입니다.",
                likeCount: 11,
                isLiked: false
            ),
            evaluation(
                id: 107,
                lectureID: 1107,
                title: "디지털미디어",
                instructor: "강태오",
                rating: 3.0,
                content: "영상과 인터랙션을 함께 다뤄 작업 범위가 넓습니다. 초반에 주제를 잘 잡으면 후반 부담이 크게 줄어듭니다.",
                likeCount: 7,
                isLiked: false
            ),
            evaluation(
                id: 108,
                lectureID: 1108,
                title: "인터랙션디자인",
                instructor: "윤하늘",
                rating: 4.0,
                content: "프로토타이핑 툴을 빠르게 써보며 피드백을 받습니다. 구현보다 상호작용의 이유를 설명하는 데 초점이 있습니다.",
                likeCount: 19,
                isLiked: false
            ),
        ]
    }

    private var latestEvaluations: [LectureEvaluation] {
        Array(recommendedEvaluations.reversed())
    }

    private func page(
        sortPrefix: String,
        evaluations: [LectureEvaluation],
        cursor: String?
    ) -> EvaluationPage {
        let pageIndex = pageIndex(from: cursor, sortPrefix: sortPrefix)
        let pageSize = 5
        let pageEvaluations = (0..<pageSize).map { offset in
            let source = evaluations[(pageIndex * pageSize + offset) % evaluations.count]
            return source.reidentified(
                id: EvaluationID(Int64(pageIndex * pageSize + offset + 10_000)),
                likeCountOffset: pageIndex + offset
            )
        }

        return EvaluationPage(
            evaluations: pageEvaluations,
            cursor: "\(sortPrefix)-page-\(pageIndex + 1)",
            isLast: false
        )
    }

    private func pageIndex(from cursor: String?, sortPrefix: String) -> Int {
        guard let cursor else { return 0 }
        let prefix = "\(sortPrefix)-page-"
        guard cursor.hasPrefix(prefix),
            let pageIndex = Int(cursor.dropFirst(prefix.count))
        else { return 0 }
        return pageIndex
    }

    private func evaluation(
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

    private func takenEvaluation(
        id: EvaluationID,
        lectureID: EvaluationLectureID,
        title: String,
        instructor: String,
        rating: Double,
        content: String,
        scores: [LectureEvaluationScore]
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
            likeCount: 12,
            isLiked: false,
            isReportable: true,
            scores: scores
        )
    }

    private func takenLecture(
        id: EvaluationLectureID,
        title: String,
        instructor: String,
        takenQuarter: Quarter,
        averageRating: Double?,
        evaluations: [LectureEvaluation]
    ) -> TakenLectureSummary {
        TakenLectureSummary(
            lecture: EvaluationLectureBrief(
                id: id,
                title: title,
                instructor: instructor
            ),
            department: "컴퓨터공학부",
            courseNumber: "M1522.000100",
            credit: 3,
            academicYear: "3",
            classification: "전공선택",
            takenQuarter: takenQuarter,
            averageRating: averageRating,
            evaluations: evaluations
        )
    }

    private var scoreSet: [LectureEvaluationScore] {
        [
            LectureEvaluationScore(title: "성적", value: 2.0),
            LectureEvaluationScore(title: "유익함", value: 5.0),
            LectureEvaluationScore(title: "강의력", value: 4.5),
            LectureEvaluationScore(title: "널널함", value: 3.5),
        ]
    }

    private func simulateNetworkDelay() async throws {
        try await Task.sleep(for: .milliseconds(150))
    }
}

extension LectureEvaluation {
    fileprivate func reidentified(id: EvaluationID, likeCountOffset: Int) -> LectureEvaluation {
        LectureEvaluation(
            id: id,
            lecture: lecture,
            rating: rating,
            content: content,
            year: year,
            semester: semester,
            likeCount: likeCount + likeCountOffset,
            isLiked: isLiked,
            isReportable: isReportable,
            scores: scores
        )
    }
}
