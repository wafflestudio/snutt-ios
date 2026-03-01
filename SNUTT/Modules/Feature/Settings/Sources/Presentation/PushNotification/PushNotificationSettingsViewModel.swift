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

    private var saveTask: Task<Void, Never>?

    var preferences: PushNotificationPreferences = .init() {
        didSet {
            saveTask?.cancel()
            saveTask = Task { await savePreferences() }
        }
    }

    func loadPreferences() async {
        do {
            preferences = try await repository.fetchPreferences()
        } catch {
            // Keep default values on failure
        }
    }

    private func savePreferences() async {
        do {
            try await repository.savePreferences(preferences)
        } catch {
            // Error handling deferred to global error handling
        }
    }
}
