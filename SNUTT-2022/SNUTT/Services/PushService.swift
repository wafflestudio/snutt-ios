//
//  PushService.swift
//  SNUTT
//
//  Created by 이채민 on 5/11/25.
//

import Foundation
import SwiftUI

@MainActor
protocol PushServiceProtocol: Sendable {
    func getPreference() async throws
    func updatePreference(options: PushNotificationOptions) async throws
}

struct PushService: PushServiceProtocol {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories

    func getPreference() async throws {
        let dto = try await pushRepository.getPreference()
        var options: PushNotificationOptions = []

        for p in dto.pushPreferences {
            switch p.type {
            case "LECTURE_UPDATE" where p.isEnabled:
                options.insert(.lectureUpdate)
            case "VACANCY_NOTIFICATION" where p.isEnabled:
                options.insert(.vacancy)
            default:
                break
            }
        }
        appState.push.options = options.isEmpty ? .default : options
    }

    func updatePreference(options: PushNotificationOptions) async throws {
        let lectureUpdate = PushPreferenceDto(
            type: "LECTURE_UPDATE",
            isEnabled: options.contains(.lectureUpdate)
        )
        let vacancyUpdate = PushPreferenceDto(
            type: "VACANCY_NOTIFICATION",
            isEnabled: options.contains(.vacancy)
        )

        try await pushRepository.updatePreference(lectureUpdate: lectureUpdate, vacancy: vacancyUpdate)
    }

    private var pushRepository: PushRepositoryProtocol {
        webRepositories.pushRepository
    }
}

class FakePushService: PushServiceProtocol {
    func getPreference() async throws {}
    func updatePreference(options _: PushNotificationOptions) async throws {}
}
