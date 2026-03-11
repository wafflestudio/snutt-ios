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

    private(set) var loadState: LoadState = .loading
    private(set) var savedPreferences: PushNotificationPreferences?

    var preferences: PushNotificationPreferences {
        get {
            guard case .loaded(let preferences) = loadState else { return .init() }
            return preferences
        }
        set {
            guard case .loaded = loadState else { return }
            loadState = .loaded(newValue)
        }
    }

    func loadPreferences() async throws {
        loadState = .loading
        let preferences = try await repository.fetchPreferences()
        savedPreferences = preferences
        loadState = .loaded(preferences)
    }

    func savePreferences(_ oldValue: PushNotificationPreferences) async throws {
        guard case .loaded(let preferences) = loadState else { return }
        do {
            try await repository.savePreferences(preferences)
            savedPreferences = preferences
        } catch {
            loadState = .loaded(oldValue)
            throw error
        }
    }
}

extension PushNotificationSettingsViewModel {
    enum LoadState {
        case loading
        case loaded(PushNotificationPreferences)
    }
}
