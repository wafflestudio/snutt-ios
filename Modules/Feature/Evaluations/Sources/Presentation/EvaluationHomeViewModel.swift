//
//  EvaluationHomeViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Observation

@MainActor
@Observable
final class EvaluationHomeViewModel {
    private(set) var homeState: LoadState<EvaluationHomeContent> = .loading
    var path: [EvaluationDestination] = []
    var writeRequest: EvaluationWriteRequest?

    @ObservationIgnored
    @Dependency(\.evaluationRepository) private var repository

    private var useCase: EvaluationHomeUseCase {
        EvaluationHomeUseCase(repository: repository)
    }

    func load() async throws {
        homeState = .loaded(try await useCase.loadHome())
    }

    func reloadTakenLectures() async throws {
        let groups = try await useCase.loadTakenLectureGroups()
        guard case .loaded(var content) = homeState else { return }
        content.takenLectureGroups = groups
        homeState = .loaded(content)
    }

    /// Reloads the feed and taken lectures in place, keeping the selected sort, to pick up
    /// evaluations written, deleted, or liked on pushed screens.
    func refresh() async throws {
        guard case .loaded(let content) = homeState else { return }
        let sort = content.selectedSort
        async let page = repository.fetchEvaluations(sort: sort, cursor: nil)
        async let groups = useCase.loadTakenLectureGroups()
        let (mainFeed, takenLectureGroups) = try await (page.items, groups)
        guard case .loaded(var currentContent) = homeState, currentContent.selectedSort == sort else { return }
        currentContent.mainFeed = mainFeed
        currentContent.takenLectureGroups = takenLectureGroups
        homeState = .loaded(currentContent)
    }

    /// Switches the feed optimistically and rolls back if the request fails.
    func selectSort(_ sort: EvaluationSort) async throws {
        guard case .loaded(let previousContent) = homeState, previousContent.selectedSort != sort else { return }

        var content = previousContent
        content.selectedSort = sort
        homeState = .loaded(content)

        do {
            let page = try await repository.fetchEvaluations(sort: sort, cursor: nil)
            guard case .loaded(var currentContent) = homeState, currentContent.selectedSort == sort else { return }
            currentContent.mainFeed = page.items
            homeState = .loaded(currentContent)
        } catch {
            guard case .loaded(let currentContent) = homeState, currentContent.selectedSort == sort else { return }
            homeState = .loaded(previousContent)
            throw error
        }
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
        try await reloadTakenLectures()
    }

    func reportEvaluation(_ id: EvaluationID, reason: String) async throws {
        try await repository.reportEvaluation(id: id, reason: reason)
    }

    /// Shows the new evaluation in its lecture's detail and refreshes the taken lecture section.
    func didCreateEvaluation(_ evaluationID: EvaluationID, for lectureID: EvaluationLectureID) async throws {
        path.append(.lectureDetail(lectureID, highlighting: evaluationID))
        try await reloadTakenLectures()
    }

    // MARK: Navigation

    func openAllEvaluations() {
        guard case .loaded(let content) = homeState else { return }
        path.append(.allEvaluations(initialSort: content.selectedSort, availableSorts: content.availableSorts))
    }

    private func updateEvaluation(_ id: EvaluationID, _ transform: (inout LectureEvaluation) -> Void) {
        guard case .loaded(var content) = homeState else { return }
        content.updateEvaluation(id, transform)
        homeState = .loaded(content)
    }
}

extension EvaluationHomeContent {
    fileprivate mutating func updateEvaluation(_ id: EvaluationID, _ transform: (inout LectureEvaluation) -> Void) {
        mainFeed = mainFeed.map { item in
            guard item.id == id else { return item }
            var item = item
            transform(&item.evaluation)
            return item
        }
        takenLectureGroups = takenLectureGroups.map { group in
            var group = group
            group.lectures = group.lectures.map { lecture in
                var lecture = lecture
                lecture.myEvaluations = lecture.myEvaluations.map { evaluation in
                    guard evaluation.id == id else { return evaluation }
                    var evaluation = evaluation
                    transform(&evaluation)
                    return evaluation
                }
                return lecture
            }
            return group
        }
    }
}
