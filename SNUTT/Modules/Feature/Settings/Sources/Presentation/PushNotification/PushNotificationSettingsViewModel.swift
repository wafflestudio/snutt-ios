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
    @Dependency(\.pushNotificationRepository) private var repository

    private var isLoaded = false
    private var saveTask: Task<Void, Never>?

    var isLectureUpdateOn: Bool = true {
        didSet {
            guard isLoaded else { return }
            saveTask?.cancel()
            saveTask = Task { await savePreferences() }
        }
    }

    var isVacancyOn: Bool = true {
        didSet {
            guard isLoaded else { return }
            saveTask?.cancel()
            saveTask = Task { await savePreferences() }
        }
    }

    var isDiaryOn: Bool = true {
        didSet {
            guard isLoaded else { return }
            saveTask?.cancel()
            saveTask = Task { await savePreferences() }
        }
    }

    func loadPreferences() async {
        isLoaded = false
        do {
            let preferences = try await repository.fetchPreferences()
            isLectureUpdateOn = preferences.isLectureUpdateEnabled
            isVacancyOn = preferences.isVacancyEnabled
            isDiaryOn = preferences.isDiaryEnabled
            isLoaded = true
        } catch {
            // Keep default values on failure
        }
    }

    private func savePreferences() async {
        do {
            let preferences = PushNotificationPreferences(
                isLectureUpdateEnabled: isLectureUpdateOn,
                isVacancyEnabled: isVacancyOn,
                isDiaryEnabled: isDiaryOn
            )
            try await repository.savePreferences(preferences)
        } catch {
            // Error handling deferred to global error handling
        }
    }
}
