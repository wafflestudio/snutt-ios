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
        let response = try await apiClient.getMySubmissions().ok.body.json
        return []
    }

    func fetchQuestionnaire(for lectureID: String, with classTypes: [String]) async throws -> [QuestionItem] {

        return []
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

extension DiarySummary {
    init(dto: Components.Schemas.DiarySubmissionSummaryDto) {
        self.init(
            id: dto.id,
            lectureID: dto.lectureId,
            date: dto.date,
            lectureTitle: dto.lectureTitle,
            shortQuestionReplies: dto.shortQuestionReplies.map {
                .init(question: $0.question, answer: $0.answer)
            },
            comment: dto.comment
        )
    }
}
