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

struct PushNotificationRepositoryKey: DependencyKey {
    static let liveValue: any PushNotificationRepository = PushNotificationAPIRepository()

    static let previewValue: any PushNotificationRepository = {
        let spy = PushNotificationRepositorySpy()
        spy.fetchPreferencesReturnValue = PushNotificationPreferences(
            isLectureUpdateEnabled: true,
            isVacancyEnabled: true
        )
        spy.savePreferencesClosure = { _ in }
        return spy
    }()
}

extension DependencyValues {
    var pushNotificationRepository: any PushNotificationRepository {
        get { self[PushNotificationRepositoryKey.self] }
        set { self[PushNotificationRepositoryKey.self] = newValue }
    }
}
