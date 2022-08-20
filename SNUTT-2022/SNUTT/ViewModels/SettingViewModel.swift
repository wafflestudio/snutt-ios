//
//  SettingViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import Foundation
import SwiftUI

class SettingViewModel: BaseSettingViewModel {
    var menuList: [[Menu]] {
        var menuList: [[Menu]] = []
        for section in menuTitles {
            var rows: [Menu] = []
            for title in section {
                rows.append(makeMenu(from: title))
            }
            menuList.append(rows)
        }
        return menuList
    }
    
    var menuTitles: [[MenuType]] {
        setting.mainMenuList
    }
    
    override init(container: DIContainer) {
        super.init(container: container)
    }
    
    private var setting: Setting {
        appState.setting
    }
    
    private var userService: UserServiceProtocol {
        container.services.userService
    }
    
    func fetchUser() async {
        do {
            try await userService.fetchUser()
        } catch {
            print("error")
        }
    }
}
