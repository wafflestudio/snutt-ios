//
//  EvaluationWriteViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import Dependencies
import Observation

@MainActor
@Observable
final class EvaluationWriteViewModel {
    enum SubmissionState: Equatable {
        case editing
        case submitting
    }

    let lectureID: EvaluationLectureID
    /// The evaluation being edited, or `nil` when writing a new one.
    let editedEvaluation: LectureEvaluation?
    private(set) var targetState: LoadState<EvaluationWriteTarget> = .loading
    private(set) var submissionState: SubmissionState = .editing
    // The form's fields are observed one by one, so typing the review updates only the views that read it.
    var semesterLectureID: SemesterLectureID?
    var rating: Double?
    var scores: [EvaluationCriterion: Double]
    var content: String
    /// The form as it was first filled in, to tell whether the user changed anything.
    private var initialDraft: EvaluationDraft

    @ObservationIgnored
    @Dependency(\.evaluationRepository) private var repository

    @ObservationIgnored
    @Dependency(\.analyticsLogger) private var analyticsLogger

    init(lectureID: EvaluationLectureID, editing evaluation: LectureEvaluation? = nil) {
        self.lectureID = lectureID
        editedEvaluation = evaluation
        let draft = evaluation.map(EvaluationDraft.init(editing:)) ?? EvaluationDraft()
        semesterLectureID = draft.semesterLectureID
        rating = draft.rating
        scores = draft.scores
        content = draft.content
        initialDraft = draft
    }

    var draft: EvaluationDraft {
        var draft = EvaluationDraft()
        draft.semesterLectureID = semesterLectureID
        draft.rating = rating
        draft.scores = scores
        draft.content = content
        return draft
    }

    var canSubmit: Bool {
        submissionState == .editing && draft.submission != nil && hasUnsavedChanges
    }

    var hasUnsavedChanges: Bool {
        draft != initialDraft
    }

    /// A semester can be picked unless it already has the user's evaluation, other than the one being edited.
    func isSelectable(_ semesterLecture: SemesterLecture) -> Bool {
        !semesterLecture.hasMyEvaluation || semesterLecture.id == initialDraft.semesterLectureID
    }

    func load() async throws {
        if targetState.isFailed { targetState = .loading }
        let target: EvaluationWriteTarget
        do {
            target = try await repository.fetchWriteTarget(lectureID: lectureID)
        } catch {
            targetState = targetState.afterFailedLoad()
            throw error
        }
        if semesterLectureID == nil {
            let semesterLecture =
                if let editedEvaluation {
                    target.semesterLectures.first { $0.quarter == editedEvaluation.quarter }
                } else {
                    target.semesterLectures.first(where: isSelectable)
                }
            semesterLectureID = semesterLecture?.id
            initialDraft.semesterLectureID = semesterLecture?.id
        }
        targetState = .loaded(target)
    }

    func submit() async throws -> EvaluationID? {
        guard canSubmit, let submission = draft.submission else { return nil }
        submissionState = .submitting
        defer { submissionState = .editing }
        if let editedEvaluation {
            try await repository.updateEvaluation(id: editedEvaluation.id, submission)
            analyticsLogger.logEvent(AnalyticsAction.editReview(evaluationID: editedEvaluation.id))
            return editedEvaluation.id
        }
        let evaluationID = try await repository.createEvaluation(submission)
        analyticsLogger.logEvent(AnalyticsAction.writeReview(lectureID: lectureID))
        return evaluationID
    }
}
