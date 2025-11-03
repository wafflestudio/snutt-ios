//
//  SettingsViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Dependencies
import DependenciesUtility
import Foundation
import FoundationUtility
import Observation
import SharedAppMetadata
import SwiftUI
import SwiftUtility
import ThemesInterface
import TimetableInterface

@MainActor
@Observable
final class SettingsViewModel {
    @ObservationIgnored
    @Dependency(\.appMetadata) private var appMetadata: AppMetadata

    @ObservationIgnored
    @Dependency(\.authUseCase) private var authUseCase

    @ObservationIgnored
    @Dependency(\.notificationCenter) var notificationCenter

    let timetableSettingsViewModel = TimetableSettingsViewModel()
    let myAccountViewModel = MyAccountViewModel()

    init() {
        Task.scoped(
            to: self,
            subscribing: vacancyNavigationNotifications()
        ) { @MainActor viewModel, element in
            viewModel.path = .init([SettingsPathType.vacancyNotification])
        }
    }

    var path = NavigationPath()

    var appVersion: String {
        "\(appMetadata[.appVersion]) (\(appMetadata[.buildNumber]))"
    }

    /// Async stream of vacancy navigation notifications
    func vacancyNavigationNotifications() -> AsyncStream<NavigateToVacancyMessage> {
        notificationCenter.messages(of: NavigateToVacancyMessage.self)
    }
}
