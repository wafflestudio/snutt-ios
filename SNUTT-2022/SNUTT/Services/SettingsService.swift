//
//  SettingsService.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/17.
//

import Foundation

protocol SettingsServiceProtocol {
    var accountSettingTitles: [[MenuType]] { get }
    var mainSettingTitles: [[MenuType]] { get }
    func setMenuList()
}

struct SettingsService: SettingsServiceProtocol {
    let appState: AppState
    let webRepositories: AppEnvironment.WebRepositories
    
    var userRepository: UserRepositoryProtocol {
        webRepositories.userRepository
    }
    
    init(appState: AppState, webRepositories: AppEnvironment.WebRepositories) {
        self.appState = appState
        self.webRepositories = webRepositories
        setMenuList()
    }
    
    /// 환경설정에서 보여줄 메뉴 목록입니다.
    var mainSettingTitles: [[MenuType]] =
        [[.accountSetting, .timetableSetting],
                [.showVersionInfo],
                [.developerInfo, .userSupport],
                [.licenseInfo, .termsOfService, .privacyPolicy],
                [.logout]]
    
    /// 환경설정 > 계정 관리에서 보여줄 메뉴 목록입니다.
    var accountSettingTitles: [[MenuType]] {
        var menu: [[MenuType]] = []
        menu.append(userLocalId == nil
                    ? [.addLocalId]
                    : [.showLocalId, .changePassword])
        menu.append(fbName == nil
                    ? [.makeFbConnection]
                    : [.showFbName, .deleteFbConnection])
        menu.append([.showEmail])
        menu.append([.deleteAccount])
        return menu
    }
    
    var userLocalId: String? {
        userRepository.userLocalId
    }
    
    var token: String? {
        userRepository.token
    }

    var fbName: String? {
        userRepository.fbName
    }
    
    func setMenuList() {
        DispatchQueue.main.async {
            appState.setting.mainMenuList = mainSettingTitles
            appState.setting.accountMenuList = accountSettingTitles
        }
    }
}

class FakeSettingsService: SettingsServiceProtocol {
    var accountSettingTitles: [[MenuType]] = []
    var mainSettingTitles: [[MenuType]] = []
    func setMenuList() {}
}
