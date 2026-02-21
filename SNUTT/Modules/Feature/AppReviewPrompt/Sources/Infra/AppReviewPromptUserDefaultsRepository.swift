//
//  AppReviewPromptUserDefaultsRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import DependenciesUtility

struct AppReviewPromptUserDefaultsRepository: AppReviewPromptRepository {
    @Dependency(\.userDefaults) private var userDefaults

    func loadState() -> AppReviewPromptState {
        userDefaults[\.appReviewPromptState]
    }

    func saveState(_ state: AppReviewPromptState) {
        userDefaults[\.appReviewPromptState] = state
    }
}

extension UserDefaultsEntryDefinitions {
    /// 앱 리뷰 프롬프트 상태 저장 키.
    var appReviewPromptState: UserDefaultsEntry<AppReviewPromptState> {
        .init(key: "appReviewPromptState", defaultValue: .initial)
    }
}
