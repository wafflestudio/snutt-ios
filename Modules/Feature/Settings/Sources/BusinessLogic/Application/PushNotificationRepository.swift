//
//  PushNotificationRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Spyable

@Spyable
protocol PushNotificationRepository: Sendable {
    func fetchPreferences() async throws -> PushNotificationPreferences
    func savePreferences(_ preferences: PushNotificationPreferences) async throws
}
