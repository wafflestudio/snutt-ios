//
//  PushNotificationUseCase.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies

struct PushNotificationUseCase {
    @Dependency(\.pushNotificationRepository) private var serverRepository

    func fetchPreferences() async throws -> PushNotificationPreferences {
        try await serverRepository.fetchPreferences()
    }

    func savePreferences(_ preferences: PushNotificationPreferences) async throws {
        try await serverRepository.savePreferences(preferences)
    }
}

struct PushNotificationUseCaseKey: DependencyKey {
    static let liveValue: PushNotificationUseCase = .init()
}

extension DependencyValues {
    var pushNotificationUseCase: PushNotificationUseCase {
        get { self[PushNotificationUseCaseKey.self] }
        set { self[PushNotificationUseCaseKey.self] = newValue }
    }
}
