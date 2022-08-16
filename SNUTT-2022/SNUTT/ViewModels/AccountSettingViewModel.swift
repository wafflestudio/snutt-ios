//
//  AccountSettingViewModel.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/01.
//

import Foundation
import SwiftUI

class AccountSettingViewModel {
    var container: DIContainer
    
    var menuTitles: [[MenuType]] {
        settingsService.accountSettingTitles
    }
    
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
        if case .addLocalId = type {
            return Menu(.addLocalId) {
                AddLocalIdScene(viewModel: AddLocalIdViewModel(container: container))
            }
        } else if case .showLocalId = type {
            return Menu(.showLocalId)
        } else if case .changePassword = type {
            return Menu(.timetableSetting) {
                TimetableSettingScene()
            }
        } else if case .makeFbConnection = type {
            return Menu(.timetableSetting) {
                TimetableSettingScene()
            }
        } else if case .showFbName = type {
            return Menu(.showFbName)
        } else if case .deleteFbConnection = type {
            return Menu(.timetableSetting) {
                TimetableSettingScene()
            }
        } else if case .showEmail = type {
            return Menu(.showEmail)
        } else if case .deleteAccount = type {
            return Menu(.timetableSetting) {
                TimetableSettingScene()
            }
        }
        return Menu(.timetableSetting)
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
    
    private var settingsService: SettingsServiceProtocol {
        container.services.settingsService
    }

    var currentUser: User {
        appState.currentUser
    }
}
