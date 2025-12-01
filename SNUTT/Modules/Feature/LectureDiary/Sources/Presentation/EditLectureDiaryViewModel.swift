//
//  EditLectureDiaryViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation
import Observation

@Observable
@MainActor
public final class EditLectureDiaryViewModel {
    @ObservationIgnored
    @Dependency(\.lectureDiaryRepository) private var repository

    private(set) var questionnaireState: QuestionnaireState = .loading
    var selectedClassTypes: [String] = []
    private(set) var selectedAnswers: [String: Int] = [:]  // questionID -> answerIndex
    var extraComment: String = ""

    let lectureID: String
    let lectureTitle: String

    public init(lectureID: String, lectureTitle: String) {
        self.lectureID = lectureID
        self.lectureTitle = lectureTitle
    }

    func loadQuestionnaire() async {
        questionnaireState = .loading

        do {
            let questions = try await repository.fetchQuestionnaire()
            questionnaireState = .loaded(questions)
        } catch {
            questionnaireState = .failed
        }
    }

    func toggleClassType(_ classType: String) {
        if selectedClassTypes.contains(classType) {
            selectedClassTypes.removeAll { $0 == classType }
        } else {
            selectedClassTypes.append(classType)
        }
    }

    func selectAnswer(questionID: String, answerIndex: Int) {
        selectedAnswers[questionID] = answerIndex
    }

    var canSubmit: Bool {
        !selectedClassTypes.isEmpty && allQuestionsAnswered
    }

    private var allQuestionsAnswered: Bool {
        guard case let .loaded(questions) = questionnaireState else {
            return false
        }
        return questions.allSatisfy { selectedAnswers[$0.id] != nil }
    }

    func submitDiary() async throws {
        let questionAnswers = selectedAnswers.map { questionID, answerIndex in
            QuestionAnswer(questionID: questionID, answerIndex: answerIndex)
        }

        let submission = DiarySubmission(
            lectureID: lectureID,
            dailyClassTypes: selectedClassTypes,
            questionAnswers: questionAnswers,
            comment: extraComment.isEmpty ? nil : extraComment
        )

        try await repository.submitDiary(submission)
    }
}

extension EditLectureDiaryViewModel {
    enum QuestionnaireState {
        case loading
        case loaded([QuestionItem])
        case failed
    }
}
