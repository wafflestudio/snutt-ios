//
//  SettingViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import Foundation
import SwiftUI

class SettingViewModel: BaseViewModel, ObservableObject {
    @Published private(set) var currentUser: User?
    @Published private(set) var preferredColorScheme: ColorScheme? = nil

    @Published var _routingState: SettingScene.RoutingState = .init()
    var routingState: SettingScene.RoutingState {
        get { _routingState }
        set {
            services.globalUIService.setRoutingState(\.settingScene, value: newValue)
        }
    }

    override init(container: DIContainer) {
        super.init(container: container)
        appState.user.$current.assign(to: &$currentUser)
        appState.system.$preferredColorScheme.assign(to: &$preferredColorScheme)
        appState.routing.$settingScene.assign(to: &$_routingState)
    }

    var userEmail: String? {
        appState.user.current?.email
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

    func getThemeList() async {
        do {
            try await services.themeService.getThemeList()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func closeBottomSheet() {
        services.themeService.closeBottomSheet()
    }
}
