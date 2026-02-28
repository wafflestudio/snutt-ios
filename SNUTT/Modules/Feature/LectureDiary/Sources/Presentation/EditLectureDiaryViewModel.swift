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
    var classTypes: [AnswerOption] = []
    var selectedClassTypes: ClassTypeSelection = .init()
    private(set) var selectedAnswers: [String: Int] = [:]  // questionID -> answerIndex
    var extraComment: String = ""

    let lectureID: String
    let lectureTitle: String

    var nextLecture: NextLecture? = nil

    public init(lectureID: String, lectureTitle: String) {
        self.lectureID = lectureID
        self.lectureTitle = lectureTitle
    }

    func getClassTypes() async {
        do {
            classTypes = try await repository.fetchClassTypeList()
        } catch {

        }
    }

    func loadQuestionnaire() async {
        questionnaireState = .loading

        do {
            let questionnaire = try await repository.fetchQuestionnaire(
                for: lectureID,
                with: selectedClassTypes.selected
            )
            nextLecture = questionnaire.nextLecture
            questionnaireState = .loaded(questionnaire.questions)
        } catch {
            questionnaireState = .failed
        }
    }

    func toggleClassType(_ classType: String) {
        if selectedClassTypes.selected.contains(classType) {
            selectedClassTypes.selected.removeAll { $0 == classType }
        } else {
            selectedClassTypes.selected.append(classType)
        }
    }

    func selectAnswer(questionID: String, answerIndex: Int) {
        selectedAnswers[questionID] = answerIndex
    }

    var canSubmit: Bool {
        !selectedClassTypes.selected.isEmpty && allQuestionsAnswered
    }

    private var allQuestionsAnswered: Bool {
        guard case .loaded(let questions) = questionnaireState else {
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
            dailyClassTypes: selectedClassTypes.selected,
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
