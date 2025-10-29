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
import SwiftUI
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
    let myAccountViewModel = MyAccountViewModel()

    var path = NavigationPath()

    var appVersion: String {
        "\(appMetadata[.appVersion]) (\(appMetadata[.buildNumber]))"
    }
}
