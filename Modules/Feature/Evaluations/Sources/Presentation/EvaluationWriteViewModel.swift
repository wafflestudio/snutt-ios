//
//  EvaluationWriteViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

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
    private(set) var targetState: LoadState<EvaluationWriteTarget> = .loading
    private(set) var submissionState: SubmissionState = .editing
    var draft = EvaluationDraft()

    @ObservationIgnored
    @Dependency(\.evaluationRepository) private var repository

    init(lectureID: EvaluationLectureID) {
        self.lectureID = lectureID
    }

    var canSubmit: Bool {
        submissionState == .editing && draft.submission != nil
    }

    var hasUnsavedChanges: Bool {
        draft.rating != nil || !draft.scores.isEmpty || !draft.content.isEmpty
    }

    func load() async throws {
        let target = try await repository.fetchWriteTarget(lectureID: lectureID)
        targetState = .loaded(target)
        if draft.semesterLectureID == nil {
            draft.semesterLectureID = target.writableSemesterLectures.first?.id
        }
    }

    func submit() async throws -> EvaluationID? {
        guard submissionState == .editing, let submission = draft.submission else { return nil }
        submissionState = .submitting
        defer { submissionState = .editing }
        return try await repository.createEvaluation(submission)
    }
}
