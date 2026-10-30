//
//  EvaluationSearchFilterUserDefaultsStore.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import DependenciesUtility
import Foundation

struct EvaluationSearchFilterUserDefaultsStore: EvaluationSearchFilterStore {
    @Dependency(\.userDefaults) private var userDefaults

    private static let key = "evaluationSearchFilterTags"

    func loadTags() -> [SearchTag] {
        guard let data = userDefaults.data(forKey: Self.key),
            let tags = try? JSONDecoder().decode([SearchTag].self, from: data)
        else { return [] }
        return tags
    }

    func saveTags(_ tags: [SearchTag]) {
        guard let data = try? JSONEncoder().encode(tags) else { return }
        userDefaults.set(data, forKey: Self.key)
    }
}
