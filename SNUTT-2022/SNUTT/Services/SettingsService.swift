//
//  SettingsService.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/17.
//

import Foundation

protocol SettingsServiceProtocol {
    var accountMenuList: [[AccountSettings]] { get }
    func updateAccountMenuList()
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
    }
    
    /// 환경설정 > 계정 관리에서 보여줄 메뉴 목록입니다.
    var accountMenuList: [[AccountSettings]] {
        var menu: [[AccountSettings]] = []
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
    
    func updateAccountMenuList() {
        DispatchQueue.main.async {
            appState.setting.accountMenuList = accountMenuList
        }
    }
}

class FakeSettingsService: SettingsServiceProtocol {
    var accountMenuList: [[AccountSettings]] = []
    func updateAccountMenuList() {}
}
