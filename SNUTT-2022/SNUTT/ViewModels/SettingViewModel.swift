//
//  SettingViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import Foundation
import SwiftUI

class SettingViewModel: BaseViewModel, ObservableObject {
    @Published var preferredColorScheme: ColorScheme? = nil
    @Published var notifications: [STNotification] = []
    @Published var unreadCount: Int = 0

    @Published var _routingState: SettingScene.RoutingState = .init()
    var routingState: SettingScene.RoutingState {
        get { _routingState }
        set {
            services.globalUIService.setRoutingState(\.settingScene, value: newValue)
        }
    }

    override init(container: DIContainer) {
        super.init(container: container)
        appState.system.$preferredColorScheme.assign(to: &$preferredColorScheme)
        appState.notification.$notifications.assign(to: &$notifications)
        appState.notification.$unreadCount.assign(to: &$unreadCount)
        appState.routing.$settingScene.assign(to: &$_routingState)
    }

    var userEmail: String? {
        appState.user.current?.email
    }

    func fetchInitialNotifications(updateLastRead: Bool) async {
        do {
            try await services.notificationService.fetchInitialNotifications(updateLastRead: updateLastRead)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func fetchMoreNotifications() async {
        do {
            try await services.notificationService.fetchMoreNotifications()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func fetchNotificationsCount() async {
        do {
            try await services.notificationService.fetchUnreadNotificationCount()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func hasNewBadge(settingName: String) -> Bool {
        services.globalUIService.hasNewBadge(settingName: settingName)
    }

    func setColorScheme(colorScheme: ColorScheme?) {
        services.globalUIService.setColorScheme(colorScheme)
    }

    var currentColorSchemeSelection: ColorSchemeSelection {
        get {
            if preferredColorScheme == .light {
                return .light
            }
            if preferredColorScheme == .dark {
                return .dark
            }
            return .automatic
        }

        set {
            switch newValue {
            case .automatic:
                setColorScheme(colorScheme: nil)
            case .light:
                setColorScheme(colorScheme: .light)
            case .dark:
                setColorScheme(colorScheme: .dark)
            }
        }
    }

    func logout() async {
        do {
            try await services.authService.logout()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func fetchUser() async {
        do {
            try await services.userService.fetchUser()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    var versionString: String {
        let appVersion = AppMetadata.appVersion.value
        let buildNumber = AppMetadata.buildNumber.value
        let appType = AppMetadata.appType.value
        return "v\(appVersion)-\(appType).\(buildNumber)"
    }

    func sendFeedback(email: String, message: String) async -> Bool {
        if !Validation.check(email: email) {
            services.globalUIService.presentErrorAlert(error: .INVALID_EMAIL)
            return false
        }
        do {
            try await services.etcService.sendFeedback(email: email, message: message)
            return true
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
            return false
        }
    }
}
