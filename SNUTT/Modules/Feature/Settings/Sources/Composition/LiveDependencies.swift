//
//  LiveDependencies.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies

struct SettingsRepositoryKey: DependencyKey {
    static let liveValue: any SettingsRepository = SettingsAPIRepository()

    static let previewValue: any SettingsRepository = {
        let spy = SettingsRepositorySpy()
        spy.postFeedbackEmailMessageClosure = { _, _ in }
        return spy
    }()
}

extension DependencyValues {
    var settingsRepository: any SettingsRepository {
        get { self[SettingsRepositoryKey.self] }
        set { self[SettingsRepositoryKey.self] = newValue }
    }
}
