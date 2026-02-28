//
//  SettingsRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Spyable

@Spyable
protocol SettingsRepository: Sendable {
    func postFeedback(email: String?, message: String) async throws
}
