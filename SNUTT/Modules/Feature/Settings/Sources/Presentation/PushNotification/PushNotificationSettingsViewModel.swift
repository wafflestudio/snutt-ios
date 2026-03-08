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
            let preferences = try await repository.fetchPreferences()
            loadState = .loaded(preferences)
        } catch {

        }
    }

    private func savePreferences() async {
        do {
            try await repository.savePreferences(preferences)
        } catch {
            // Error handling
        }
    }
}

extension PushNotificationSettingsViewModel {
    enum LoadState {
        case loading
        case loaded(PushNotificationPreferences)
    }
}
