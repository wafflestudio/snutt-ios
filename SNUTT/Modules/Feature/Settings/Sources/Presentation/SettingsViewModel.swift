//
//  SettingsViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Dependencies
import Foundation
import FoundationUtility
import Observation
import SharedAppMetadata
import ThemesInterface
import TimetableInterface

@MainActor
@Observable
final class SettingsViewModel {
    @ObservationIgnored
    @Dependency(\.appMetadata) private var appMetadata: AppMetadata

    @ObservationIgnored
    @Dependency(\.authUseCase) private var authUseCase

    let timetableSettingsViewModel = TimetableSettingsViewModel()

    // FIXME: load actual user nickname
    var userNickname: String = "와플#7777"

    var appVersion: String {
        appMetadata[.appVersion]
    }

    func fetchUser() async throws {}

    func logout() async throws {
        try await authUseCase.logout()
    }
}
