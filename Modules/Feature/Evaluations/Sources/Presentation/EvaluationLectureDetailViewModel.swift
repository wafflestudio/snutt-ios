//
//  EvaluationLectureDetailViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Observation

@MainActor
@Observable
final class EvaluationLectureDetailViewModel {
    struct Content: Equatable {
        var summary: LectureEvaluationSummary
        /// The current user's evaluations, which the lecture feed excludes.
        var myEvaluations: [LectureEvaluation]
        var evaluations: PagedContent<LectureEvaluation>

        /// Every evaluation in display order: the user's own first, then everyone else's.
        var allEvaluations: [LectureEvaluation] {
            myEvaluations + evaluations.items
        }
    }

    let lectureID: EvaluationLectureID
    private(set) var contentState: LoadState<Content> = .loading
    /// An evaluation to scroll to and briefly highlight, such as one the user just wrote.
    private(set) var highlightedEvaluationID: EvaluationID?
    var writeRequest: EvaluationWriteRequest?

    @ObservationIgnored
    @Dependency(\.evaluationRepository) private var repository

    @ObservationIgnored
    private var isLoadingMore = false

    init(lectureID: EvaluationLectureID, highlightedEvaluationID: EvaluationID? = nil) {
        self.lectureID = lectureID
        self.highlightedEvaluationID = highlightedEvaluationID
    }

    func load() async throws {
        async let summary = repository.fetchLectureSummary(lectureID: lectureID)
        async let myEvaluations = repository.fetchMyLectureEvaluations(lectureID: lectureID)
        async let firstPage = repository.fetchLectureEvaluations(lectureID: lectureID, cursor: nil)
        contentState = .loaded(
            Content(
                summary: try await summary,
                myEvaluations: try await myEvaluations,
                evaluations: PagedContent(try await firstPage)
            )
        )
    }

    /// Pagination is driven by scrolling, so failures stay silent and the next scroll retries.
    func loadMoreIfNeeded(after evaluation: LectureEvaluation) async {
        guard case .loaded(let content) = contentState,
            let cursor = content.evaluations.nextCursor,
            content.evaluations.items.suffix(5).contains(where: { $0.id == evaluation.id }),
            !isLoadingMore
        else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        guard let page = try? await repository.fetchLectureEvaluations(lectureID: lectureID, cursor: cursor),
            case .loaded(var currentContent) = contentState,
            currentContent.evaluations.nextCursor == cursor
        else { return }
        currentContent.evaluations = currentContent.evaluations.appending(page)
        contentState = .loaded(currentContent)
    }

    func toggleLike(_ evaluation: LectureEvaluation) async throws {
        let toggledLike = evaluation.like.toggled()
        updateEvaluation(evaluation.id) { $0.like = toggledLike }
        do {
            try await repository.setLiked(toggledLike.isLiked, evaluationID: evaluation.id)
        } catch {
            updateEvaluation(evaluation.id) { $0.like = evaluation.like }
            throw error
        }
    }

    func deleteEvaluation(_ id: EvaluationID) async throws {
        try await repository.deleteEvaluation(id: id)
        try await load()
    }

    func reportEvaluation(_ id: EvaluationID, reason: String) async throws {
        try await repository.reportEvaluation(id: id, reason: reason)
    }

    func openWriteEvaluation() {
        writeRequest = EvaluationWriteRequest(lectureID: lectureID)
    }

    func didCreateEvaluation(_ id: EvaluationID) async throws {
        highlightedEvaluationID = id
        try await load()
    }

    func clearHighlight() {
        highlightedEvaluationID = nil
    }

    private func updateEvaluation(_ id: EvaluationID, _ transform: (inout LectureEvaluation) -> Void) {
        guard case .loaded(var content) = contentState else { return }
        content.evaluations.update(id, transform)
        content.myEvaluations = content.myEvaluations.map { evaluation in
            guard evaluation.id == id else { return evaluation }
            var evaluation = evaluation
            transform(&evaluation)
            return evaluation
        }
        contentState = .loaded(content)
    }
}
