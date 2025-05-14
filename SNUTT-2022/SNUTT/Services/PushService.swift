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
    func updatePreference(isLectureUpdatePushOn: Bool, isVacancyPushOn: Bool) async throws
}

struct PushService: PushServiceProtocol {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories

    func getPreference() async throws {
        let dto = try await pushRepository.getPreference()

        var isLectureUpdatePushOn = true
        var isVacancyPushOn = true

        for preference in dto.pushPreferences {
            switch preference.type {
            case "LECTURE_UPDATE":
                isLectureUpdatePushOn = preference.isEnabled
            case "VACANCY_NOTIFICATION":
                isVacancyPushOn = preference.isEnabled
            default:
                break
            }
        }

        appState.push.isLectureUpdatePushOn = isLectureUpdatePushOn
        appState.push.isVacancyPushOn = isVacancyPushOn
    }

    func updatePreference(isLectureUpdatePushOn: Bool, isVacancyPushOn: Bool) async throws {
        let lectureUpdate = PushPreferenceDto(
            type: "LECTURE_UPDATE",
            isEnabled: isLectureUpdatePushOn
        )
        let vacancy = PushPreferenceDto(
            type: "VACANCY_NOTIFICATION",
            isEnabled: isVacancyPushOn
        )
        try await pushRepository.updatePreference(lectureUpdate: lectureUpdate, vacancy: vacancy)
    }

    private var pushRepository: PushRepositoryProtocol {
        webRepositories.pushRepository
    }
}

class FakePushService: PushServiceProtocol {
    func getPreference() async throws {}
    func updatePreference(isLectureUpdatePushOn _: Bool, isVacancyPushOn _: Bool) async throws {}
}
