//
//  SettingsViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Auth
import Dependencies
import Foundation
import Observation
import SharedAppMetadata
import Timetable
import TimetableInterface
import TimetableUIComponents

@MainActor
@Observable final class SettingsViewModel {
    
    @ObservationIgnored
    @Dependency(\.appMetadata) private var appMetadata: AppMetadata
    
    @ObservationIgnored
    @Dependency(\.authUseCase) private var authUseCase: AuthUseCase
    
    @ObservationIgnored
    @Dependency(\.timetableUseCase) private var timetableUseCase: TimetableUseCase
    
    private(set) var currentTimetable: (any Timetable)?
    
    // FIXME: use shared config
    var configuration: TimetableConfiguration = .init()
    
    var appVersion: String {
        appMetadata[.appVersion]
    }
    
    func makePainter() -> TimetablePainter {
        TimetablePainter(
            currentTimetable: currentTimetable,
            selectedLecture: nil,
            selectedTheme: currentTimetable?.defaultTheme ?? .snutt,
            configuration: configuration
        )
    }

    func loadTimetable() async throws {
        currentTimetable = try await timetableUseCase.loadRecentTimetable()
    }
    
    func logout() async throws {
        try await authUseCase.logout()
    }
}
