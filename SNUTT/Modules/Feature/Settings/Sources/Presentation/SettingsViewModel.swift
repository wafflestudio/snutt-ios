//
//  SettingsViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Dependencies
import Foundation
import Observation
import SharedAppMetadata
import ThemesInterface
import TimetableInterface
import TimetableUIComponents

@MainActor
@Observable
final class SettingsViewModel {
    @ObservationIgnored
    @Dependency(\.appMetadata) private var appMetadata: AppMetadata

    @ObservationIgnored
    @Dependency(\.authUseCase) private var authUseCase

    // FIXME: load currentTimetable
    private(set) var currentTimetable: Timetable?

    // FIXME: use shared config
    var configuration: TimetableConfiguration = .init()

    var appVersion: String {
        appMetadata[.appVersion]
    }

    func fetchUser() async throws {}

    func makePainter() -> TimetablePainter {
        TimetablePainter(
            currentTimetable: currentTimetable,
            selectedLecture: nil,
            preferredTheme: nil,
            availableThemes: [],
            configuration: configuration
        )
    }

    func logout() async throws {
        try await authUseCase.logout()
    }
}
