//
//  DiaryDto.swift
//  SNUTT
//
//  Created by 최유림 on 9/7/25.
//

import Foundation

struct DiaryDto: Encodable {
    let lectureId: String
    let dailyClassTypes: [String]
    let questionAnswers: [QuestionAnswerDto]
    let comment: String
}

struct QuestionAnswerDto: Encodable {
    let questionId: String
    let answerIndex: Int
}

struct ClassCategoryDto: Decodable {
    let id: String
    let name: String
}

// MARK: Diary Summary for 'SettingsTab'
struct DiarySummaryListDto: Decodable {
    let year: Int
    let semester: Int
    let submissions: [DiarySummaryDto]
}

struct DiarySummaryDto: Decodable {
    let id: String
    let lectureId: String
    let date: String
    let lectureTitle: String
    let shortQuestionReplies: [ShortAnswerReply]
    let comment: String
}

struct ShortAnswerReply: Decodable {
    let question: String
    let answer: String
}

// MARK: Request Questionnaire List
struct DiaryQuestionnaireRequestDto: Codable {
    let lectureId: String
    let dailyClassTypes: [String]
}

struct DiaryQuestionnaireResponseDto: Decodable {
    let lectureTitle: String
    let questions: [DiaryQuestionnaireWithId]
    let nextLectureId: String
    let nextLectureTitle: String
}

struct DiaryQuestionnaireWithId: Decodable {
    let id: String
    let question: String
    let answers: [String]
}
