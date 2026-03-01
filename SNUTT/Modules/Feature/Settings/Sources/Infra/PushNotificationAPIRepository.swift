//
//  PushNotificationAPIRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies

struct PushNotificationAPIRepository: PushNotificationRepository {
    @Dependency(\.apiClient) private var apiClient

    func fetchPreferences() async throws -> PushNotificationPreferences {
        let prefs = try await apiClient.getPushPreferences().ok.body.json.pushPreferences
        let prefMap = Dictionary(uniqueKeysWithValues: prefs.map { ($0._type, $0.isEnabled) })
        return PushNotificationPreferences(
            isLectureUpdateEnabled: prefMap[.LECTURE_UPDATE] ?? true,
            isVacancyEnabled: prefMap[.VACANCY_NOTIFICATION] ?? true,
            isDiaryEnabled: prefMap[.DIARY] ?? true
        )
    }

    func savePreferences(_ preferences: PushNotificationPreferences) async throws {
        _ = try await apiClient.savePushPreferences(
            body: .json(
                .init(pushPreferences: [
                    .init(isEnabled: preferences.isLectureUpdateEnabled, _type: .LECTURE_UPDATE),
                    .init(isEnabled: preferences.isVacancyEnabled, _type: .VACANCY_NOTIFICATION),
                    .init(isEnabled: preferences.isDiaryEnabled, _type: .DIARY),
                ])
            )
        ).ok
    }
}
