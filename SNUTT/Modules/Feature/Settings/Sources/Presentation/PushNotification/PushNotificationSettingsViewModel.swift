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

    var preferences: PushNotificationPreferences = .init() {
        didSet {
            guard isLoaded else { return }
            saveTask?.cancel()
            saveTask = Task { await savePreferences() }
        }
    }

    func loadPreferences() async {
        isLoaded = false
        do {
            preferences = try await repository.fetchPreferences()
            isLoaded = true
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
