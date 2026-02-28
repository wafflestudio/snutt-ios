//
//  LectureDiaryAPIRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import Foundation
import TimetableInterface

struct LectureDiaryAPIRepository: LectureDiaryRepository {
    @Dependency(\.apiClient) private var apiClient

    init() {}

    func fetchClassTypeList() async throws -> [AnswerOption] {
        let response = try await apiClient.getDailyClassTypes().ok.body.json
        return response.map { .init(id: $0.id, content: $0.name) }
    }

    public func fetchDiaryList() async throws -> [DiarySubmissionsOfYearSemester] {
        try await apiClient.getMySubmissions().ok.body.json.map { try $0.toDiaryList() }
    }

    func fetchQuestionnaire(for lectureID: String, with classTypes: [String]) async throws -> QuestionnaireItem {
        let requestDto = Components.Schemas.DiaryQuestionnaireRequestDto(
            dailyClassTypes: classTypes,
            lectureId: lectureID
        )
        let response = try await apiClient.getQuestionnaireFromDailyClassTypes(body: .json(requestDto)).ok.body.json
        return .init(dto: response)
    }

    public func submitDiary(_ submission: DiarySubmission) async throws {
        let requestDto = Components.Schemas.DiarySubmissionRequestDto(
            comment: submission.comment ?? "",
            dailyClassTypes: submission.dailyClassTypes,
            lectureId: submission.lectureID,
            questionAnswers: submission.questionAnswers.map {
                .init(answerIndex: Int32($0.answerIndex), questionId: $0.questionID)
            }
        )
        let _ = try await apiClient.submitDiary(body: .json(requestDto))
    }

    public func deleteDiary(diaryID: String) async throws {
        let _ = try await apiClient.removeDiarySubmission(path: .init(id: diaryID))
    }
}

// MARK: - DTO Conversion (Infra layer only)

extension QuestionnaireItem {
    init(dto: Components.Schemas.DiaryQuestionnaireDto) {
        self.init(
            lectureTitle: dto.courseTitle,
            questions: dto.questions.map {
                .init(
                    id: $0.id,
                    question: $0.question,
                    subQuestion: nil,
                    options: $0.answers.enumerated().map { (index, answer) in
                        .init(id: "\(index)", content: answer)
                    }
                )
            },
            nextLecture: dto.nextLecture.map { .init(id: $0.lectureId, title: $0.courseTitle) }
        )
    }
}

extension Components.Schemas.DiarySubmissionsOfYearSemesterDto {
    func toDiaryList() throws -> DiarySubmissionsOfYearSemester {
        .init(
            quarter: .init(year: Int(year), semester: try require(Semester(rawValue: Int(semester)))),
            diaryList: submissions.map { .init(dto: $0) }
        )
    }
}

extension DiarySummary {
    init(dto: Components.Schemas.DiarySubmissionSummaryDto) {
        self.init(
            id: dto.id,
            lectureID: dto.lectureId,
            date: dto.date,
            lectureTitle: dto.courseTitle,
            shortQuestionReplies: dto.shortQuestionReplies.map {
                .init(question: $0.question, answer: $0.answer)
            },
            comment: dto.comment
        )
    }
}
