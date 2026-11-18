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
import LectureDiaryInterface
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
    let referrer: DiaryWriteReferrer

    @ObservationIgnored private var hasReachedQuestions = false
    @ObservationIgnored private var isExitLogged = false
    private(set) var isSubmitting = false

    var nextLecture: NextLecture? = nil

    var canSubmit: Bool {
        !selectedClassTypes.selected.isEmpty && allQuestionsAnswered && !isSubmitting
    }

    private var allQuestionsAnswered: Bool {
        guard case .loaded(let questions) = questionnaireState else {
            return false
        }
        return questions.allSatisfy { selectedAnswers[$0.id] != nil }
    }

    public init(lectureID: LectureID, lectureTitle: String, referrer: DiaryWriteReferrer) {
        self.lectureID = lectureID
        self.lectureTitle = lectureTitle
        self.referrer = referrer
    }

    func getClassTypes() async throws {
        classTypes = try await repository.fetchClassTypeList()
    }

    func loadQuestionnaire() async {
        questionnaireState = .loading
        hasReachedQuestions = true

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
        // Throw rather than return so the caller does not show the confirm screen for a duplicate tap.
        guard !isSubmitting else { throw CancellationError() }
        isSubmitting = true

        let questionAnswers = selectedAnswers.map { questionID, answerIndex in
            QuestionAnswer(questionID: questionID, answerIndex: answerIndex)
        }

        let submission = DiarySubmission(
            lectureID: lectureID,
            dailyClassTypes: selectedClassTypes.selected,
            questionAnswers: questionAnswers,
            comment: extraComment.isEmpty ? nil : extraComment
        )

        do {
            try await repository.submitDiary(submission)
        } catch {
            // Stays true on success so the button cannot be tapped again before the confirm screen appears.
            isSubmitting = false
            throw error
        }

        let selectedClassTypeIDs = selectedClassTypes.selected.compactMap { content in
            classTypes.first { $0.content == content }?.id
        }
        analyticsLogger.logEvent(
            AnalyticsAction.diarySubmitted(
                .init(
                    activityTypeIDs: selectedClassTypeIDs,
                    hasComment: submission.comment != nil,
                    referrer: referrer
                )
            )
        )
    }

    /// Logs `diary_write_exit` when the user leaves the write screen without submitting.
    func logExitWithoutSubmit() {
        guard !isExitLogged else { return }
        isExitLogged = true
        analyticsLogger.logEvent(
            AnalyticsAction.diaryWriteExit(
                .init(
                    step: hasReachedQuestions ? .questions : .activity,
                    referrer: referrer
                )
            )
        )
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
