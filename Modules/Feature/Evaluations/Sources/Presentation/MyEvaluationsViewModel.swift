//
//  MyEvaluationsViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Observation
import TimetableInterface

@MainActor
@Observable
final class MyEvaluationsViewModel {
    /// The user's evaluations written in one semester.
    struct Section: Equatable, Identifiable {
        let quarter: Quarter
        let items: [EvaluationWithLecture]

        var id: Quarter { quarter }
    }

    private(set) var evaluationsState: LoadState<PagedContent<EvaluationWithLecture>> = .loading

    @ObservationIgnored
    @Dependency(\.evaluationRepository) private var repository

    @ObservationIgnored
    private var isLoadingMore = false

    /// Sections in the order the server returns evaluations, which is most recent first.
    var sections: [Section]? {
        guard case .loaded(let content) = evaluationsState else { return nil }
        return content.items.reduce(into: []) { sections, item in
            let quarter = item.evaluation.quarter
            if let lastSection = sections.last, lastSection.quarter == quarter {
                sections[sections.count - 1] = Section(quarter: quarter, items: lastSection.items + [item])
            } else {
                sections.append(Section(quarter: quarter, items: [item]))
            }
        }
    }

    func load() async throws {
        evaluationsState = .loaded(PagedContent(try await repository.fetchMyEvaluations(cursor: nil)))
    }

    /// Pagination is driven by scrolling, so failures stay silent and the next scroll retries.
    func loadMoreIfNeeded(after item: EvaluationWithLecture) async {
        guard case .loaded(let content) = evaluationsState,
            let cursor = content.nextCursor,
            content.items.suffix(5).contains(where: { $0.id == item.id }),
            !isLoadingMore
        else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        guard let page = try? await repository.fetchMyEvaluations(cursor: cursor),
            case .loaded(let currentContent) = evaluationsState,
            currentContent.nextCursor == cursor
        else { return }
        evaluationsState = .loaded(currentContent.appending(page))
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
        guard case .loaded(var content) = evaluationsState else { return }
        content.remove(id)
        evaluationsState = .loaded(content)
    }

    private func updateEvaluation(_ id: EvaluationID, _ transform: (inout LectureEvaluation) -> Void) {
        guard case .loaded(var content) = evaluationsState else { return }
        content.update(id) { transform(&$0.evaluation) }
        evaluationsState = .loaded(content)
    }
}
