//
//  SettingsAPIRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import Foundation

struct SettingsAPIRepository: SettingsRepository {
    @Dependency(\.apiClient) private var apiClient

    func postFeedback(email: String?, message: String) async throws {
        _ = try await apiClient.postFeedback(body: .json(.init(email: email ?? "unknown", message: message))).ok
    }
}
