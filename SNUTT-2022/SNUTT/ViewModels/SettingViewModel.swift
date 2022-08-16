//
//  SettingViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import Foundation
import SwiftUI

class SettingViewModel {
    var container: DIContainer
    
    var menuList: [[Menu]] {
        var menuList: [[Menu]] = []
        for section in menuTitles {
            var temp: [Menu] = []
            for title in section {
                temp.append(makeMenu(with: title))
            }
            menuList.append(temp)
        }
        return menuList
    }
    
    func makeMenu(with type: MenuType) -> Menu {
        if case .accountSetting = type {
            return Menu(.accountSetting) {
                AccountSettingScene(viewModel: AccountSettingViewModel(container: container))
            }
        } else if case .timetableSetting = type {
            return Menu(.timetableSetting) {
                TimetableSettingScene()
            }
        } else if case .showVersionInfo = type {
            return Menu(.showVersionInfo)
        } else if case .developerInfo = type {
            return Menu(.developerInfo) {
                DeveloperInfoScene()
            }
        } else if case .userSupport = type {
            return Menu(.userSupport) {
                DeveloperInfoScene()
            }
        } else if case .licenseInfo = type {
            return Menu(.licenseInfo) {
                LicenseScene()
            }
        } else if case .termsOfService = type {
            return Menu(.termsOfService) {
                TermsOfServiceScene()
            }
        } else if case .privacyPolicy = type {
            return Menu(.privacyPolicy) {
                PrivacyPolicyScene()
            }
        } else if case .logout = type {
            return Menu(.logout)
        }
        return Menu(.timetableSetting)
    }
    
    var menuTitles: [[MenuType]] {
        container.services.settingsService.mainSettingTitles
    }
    
    var appVersion: String {
        // WIP
        return ""
    }

    init(container: DIContainer) {
        self.container = container
    }

    private var appState: AppState {
        container.appState
    }
    
    private var userService: UserServiceProtocol {
        container.services.userService
    }

    var currentUser: User {
        appState.currentUser
    }

    func updateCurrentUser(user: User) {
        appState.currentUser = user
    }
}
