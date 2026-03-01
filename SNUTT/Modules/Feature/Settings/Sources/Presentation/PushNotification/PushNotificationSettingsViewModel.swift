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
    private(set) var loadState: LoadState = .loading

    var preferences: PushNotificationPreferences = .init() {
        didSet {
            guard case .loaded = loadState else { return }
            saveTask?.cancel()
            saveTask = Task { await savePreferences() }
        }
    }

    func loadPreferences() async {
        loadState = .loading
        do {
            preferences = try await repository.fetchPreferences()
            loadState = .loaded
        } catch {
            loadState = .failed
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
