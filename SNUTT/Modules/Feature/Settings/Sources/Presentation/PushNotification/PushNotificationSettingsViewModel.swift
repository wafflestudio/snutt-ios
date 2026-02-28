//
//  PushNotificationSettingsViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import Observation

@MainActor
@Observable
final class PushNotificationSettingsViewModel {

    private var isLoaded = false

    var isLectureUpdateOn: Bool = true {
        didSet {
            guard isLoaded else { return }
            Task { await savePreferences() }
        }
    }

    var isVacancyOn: Bool = true {
        didSet {
            guard isLoaded else { return }
            Task { await savePreferences() }
        }
    }

    func loadPreferences() async {
        isLoaded = false
        do {
            isLectureUpdateOn = true
            isVacancyOn = true
        } catch {
            // Keep default values on failure
        }
        isLoaded = true
    }

    private func savePreferences() async {
        do {
            // TODO
        } catch {
            // Error handling deferred to global error handling
        }
    }
}
