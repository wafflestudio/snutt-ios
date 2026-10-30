//
//  EvaluationFilterViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Observation

@MainActor
@Observable
final class EvaluationFilterViewModel {
    private(set) var groupsState: LoadState<[SearchTagGroup]> = .loading
    var selectedGroupID: SearchTagGroup.ID?
    /// Selected tags in the order the user picked them, which is the order chips appear in.
    private(set) var selectedTags: [SearchTag]

    @ObservationIgnored
    @Dependency(\.evaluationRepository) private var repository

    init(selectedTags: [SearchTag]) {
        self.selectedTags = selectedTags
    }

    var selectedGroup: SearchTagGroup? {
        groupsState.value?.first { $0.id == selectedGroupID }
    }

    func load() async throws {
        let groups = try await repository.fetchSearchTagGroups()
        groupsState = .loaded(groups)
        if selectedGroupID == nil {
            selectedGroupID = groups.first?.id
        }
    }

    func isSelected(_ tag: SearchTag) -> Bool {
        selectedTags.contains(tag)
    }

    func toggle(_ tag: SearchTag) {
        if isSelected(tag) {
            selectedTags.removeAll { $0 == tag }
        } else {
            selectedTags.append(tag)
        }
    }

    func selectedCount(in group: SearchTagGroup) -> Int {
        group.tags.count(where: isSelected)
    }
}
