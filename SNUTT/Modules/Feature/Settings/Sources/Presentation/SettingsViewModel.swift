//
//  SettingsViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Dependencies
import DependenciesUtility
import Foundation
import FoundationUtility
import LectureDiaryInterface
import NotificationsInterface
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

    @ObservationIgnored
    @Dependency(\.notificationCountRepository) private var notificationCountRepository

    let timetableSettingsViewModel = TimetableSettingsViewModel()
    let myAccountViewModel = MyAccountViewModel()
    let pushNotificationSettingsViewModel = PushNotificationSettingsViewModel()

    private(set) var unreadNotificationCount: Int = 0

    init() {
        Task.scoped(
            to: self,
            subscribing: notificationInboxNavigationNotifications()
        ) { @MainActor viewModel, _ in
            viewModel.path = .init([SettingsPathType.notificationInbox])
        }

        Task.scoped(
            to: self,
            subscribing: vacancyNavigationNotifications()
        ) { @MainActor viewModel, element in
            viewModel.path = .init([SettingsPathType.vacancyNotification])
        }

        Task.scoped(
            to: self,
            subscribing: lectureReminderNavigationNotifications()
        ) { @MainActor viewModel, element in
            viewModel.path = .init([SettingsPathType.lectureReminder])
        }

        Task.scoped(
            to: self,
            subscribing: pushNotificationSettingsNavigationNotifications()
        ) { @MainActor viewModel, _ in
            viewModel.path = .init([SettingsPathType.pushNotificationSettings])
        }
    }

    var path = NavigationPath()

    var appVersion: String {
        "\(appMetadata[.appVersion]) (\(appMetadata[.buildNumber]))"
    }

    func loadUnreadNotificationCount() async throws {
        unreadNotificationCount = try await notificationCountRepository.fetchUnreadNotificationCount()
    }

    /// Async stream of vacancy navigation notifications
    func vacancyNavigationNotifications() -> AsyncStream<NavigateToVacancyMessage> {
        notificationCenter.messages(of: NavigateToVacancyMessage.self)
    }

    /// Async stream of lecture reminder navigation notifications
    func lectureReminderNavigationNotifications() -> AsyncStream<NavigateToLectureRemindersMessage> {
        notificationCenter.messages(of: NavigateToLectureRemindersMessage.self)
    }

    /// Async stream of notification inbox navigation notifications
    func notificationInboxNavigationNotifications() -> AsyncStream<NavigateToNotificationsMessage> {
        notificationCenter.messages(of: NavigateToNotificationsMessage.self)
    }

    /// Async stream of push notification settings navigation notifications
    func pushNotificationSettingsNavigationNotifications() -> AsyncStream<NavigateToPushNotificationSettingsMessage> {
        notificationCenter.messages(of: NavigateToPushNotificationSettingsMessage.self)
    }
}
