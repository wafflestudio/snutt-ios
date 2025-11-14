//
//  LectureDiary.swift
//  SNUTT
//
//  Created by 최유림 on 5/28/25.
//

import Foundation

struct DiaryListPerSemester {
    let year: Int
    let semester: Semester
    var diaryList: [DiarySummary]
    
    var yearAndSemester: String {
        "\(String(year).suffix(2))-\(semester.mediumString())"
    }
}

extension DiaryListPerSemester {
    init(from dto: DiarySummaryListDto) {
        self.year = dto.year
        self.semester = .init(rawValue: dto.semester) ?? .first
        self.diaryList = dto.submissions.map { .init(from: $0) }
    }
}

struct DiarySummary {
    let id: String
    let lectureId: String
    let lectureTitle: String
    private let date: String
    let shortQuestionReplies: [ShortAnswerReply]
    let comment: String?
    
    var dateString: String {
        let date = DateFormatter.parse(string: date)
        return DateFormatter.parse(date: date, format: "yyyy.M.dd")
    }
    
    var weekdayString: String {
        let date = DateFormatter.parse(string: date)
        return DateFormatter.parse(date: date, format: "EEEEE")
    }
}

extension DiarySummary {
    init(from dto: DiarySummaryDto) {
        self.id = dto.id
        self.lectureId = dto.lectureId
        self.lectureTitle = dto.lectureTitle
        self.date = dto.date
        self.shortQuestionReplies = dto.shortQuestionReplies
        self.comment = dto.comment
    }
}

struct DiaryQuestionnaire {
    let lectureTitle: String
    let questions: [QuestionItem]
    let nextLectureId: String
    let nextLectureTitle: String
}

extension DiaryQuestionnaire {
    init(from dto: QuestionnaireResponseDto) {
        self.lectureTitle = dto.lectureTitle
        self.questions = dto.questions.map { .init(from: $0) }
        self.nextLectureId = dto.nextLectureId
        self.nextLectureTitle = dto.nextLectureTitle
    }
}

struct QuestionItem {
    let question: String
    var subQuestion: String? = nil
    let options: [AnswerOption]
}

struct AnswerOption: Equatable {
    let id: Int
    let content: String
}

extension QuestionItem {
    init(from dto: QuestionnaireWithIdDto) {
        self.question = dto.question
        self.options = dto.answers.enumerated().map { .init(id: $0.0, content: $0.1) }
    }
}

extension DiarySummary {
    static let preview1: Self = .init(
        id: "1",
        lectureId: "123",
        lectureTitle: "시각디자인기초",
        date: "2025-10-29T12:42:58.300Z",
        shortQuestionReplies: [
            .init(question: "수강신청", answer: "널널해요"),
            .init(question: "드랍여부", answer: "모르겠어요"),
            .init(question: "수업 첫인상", answer: "두려워요")
        ],
        comment: "오티 했어용. 교수님이 과제량 많다고 하셨는데 도움이 많이 될 것 같아 기대가 돼요. 수업 들으려고 과외도 끊었지 뭐에요 😮‍💨"
    )
    static let preview2: Self = .init(
        id: "2",
        lectureId: "456",
        lectureTitle: "배구",
        date: "2025-10-29T12:42:58.300Z",
        shortQuestionReplies: [
            .init(question: "수강신청", answer: "널널해요"),
            .init(question: "드랍여부", answer: "모르겠어요"),
            .init(question: "수업 첫인상", answer: "두려워요")
        ],
        comment: "오티 했어용. 교수님이 과제량 많다고 하셨는데 도움이 많이 될 것 같아 기대가 돼요. 수업 들으려고 과외도 끊었지 뭐에요 😮‍💨"
    )
}

extension DiaryQuestionnaire {
    static let preview: Self = .init(
        lectureTitle: "시각디자인기초",
        questions: [
            .init(
                question: "수강신청",
                options: [
                    .init(id: 1, content: "널널해요"),
                    .init(id: 2, content: "무난해요"),
                    .init(id: 3, content: "어려웠어요")
                ]
            )
        ],
        nextLectureId: "",
        nextLectureTitle: ""
    )
}
