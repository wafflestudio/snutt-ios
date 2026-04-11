#if FEATURE_LECTURE_DIARY
//
//  EditLectureDiaryViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import Dependencies
import Foundation
import Observation
import TimetableInterface

@Observable
@MainActor
public final class EditLectureDiaryViewModel {
    @ObservationIgnored
    @Dependency(\.lectureDiaryRepository) private var repository

    @ObservationIgnored
    @Dependency(\.analyticsLogger) private var analyticsLogger

    private(set) var questionnaireState: QuestionnaireState = .loading
    var classTypes: [AnswerOption] = []
    var selectedClassTypes: ClassTypeSelection = .init()
    private(set) var selectedAnswers: [String: Int] = [:]  // questionID -> answerIndex
    var extraComment: String = ""

    let lectureID: LectureID
    let lectureTitle: String

    var nextLecture: NextLecture? = nil

    var canSubmit: Bool {
        !selectedClassTypes.selected.isEmpty && allQuestionsAnswered
    }

    private var allQuestionsAnswered: Bool {
        guard case .loaded(let questions) = questionnaireState else {
            return false
        }
        return questions.allSatisfy { selectedAnswers[$0.id] != nil }
    }

    public init(lectureID: LectureID, lectureTitle: String) {
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
            analyticsLogger.logEvent(AnalyticsAction.diaryFirstSectionDone)
            let questionnaire = try await repository.fetchQuestionnaire(
                for: lectureID,
                with: selectedClassTypes.selected
            )
            nextLecture = questionnaire.nextLecture
            questionnaireState = .loaded(questionnaire.questions.sorted { $0.id < $1.id })
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

        analyticsLogger.logEvent(AnalyticsAction.diarySubmitted)
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
#endif
