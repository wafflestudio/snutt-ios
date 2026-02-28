//
//  PushNotificationSettingsViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Observation

@MainActor
@Observable
final class PushNotificationSettingsViewModel {
    @ObservationIgnored
    @Dependency(\.pushNotificationUseCase) private var useCase

    private var isLoaded = false

    var isLectureUpdateOn: Bool = true {
        didSet {
            guard isLoaded else { return }
            Task { await savePreferences() }
        }
    }

    var isVacancyOn: Bool = true {
        didSet {
            guard isLoaded else { return }
            Task { await savePreferences() }
        }
    }

    func loadPreferences() async {
        isLoaded = false
        do {
            let preferences = try await useCase.fetchPreferences()
            isLectureUpdateOn = preferences.isLectureUpdateEnabled
            isVacancyOn = preferences.isVacancyEnabled
        } catch {
            // Keep default values on failure
        }
        isLoaded = true
    }

    private func savePreferences() async {
        do {
            let preferences = PushNotificationPreferences(
                isLectureUpdateEnabled: isLectureUpdateOn,
                isVacancyEnabled: isVacancyOn
            )
            try await useCase.savePreferences(preferences)
        } catch {
            // Error handling deferred to global error handling
        }
    }
}
