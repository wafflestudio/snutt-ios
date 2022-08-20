//
//  AccountSettingViewModel.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/01.
//

import SwiftUI
import Combine

class AccountSettingViewModel: BaseSettingViewModel, ObservableObject {

    private var bag = Set<AnyCancellable>()
    
    @Published var menuList: [[Menu]] = []
    
    override init(container: DIContainer) {
        super.init(container: container)
        
        userState.$current
            .sink { user in
                self.settingsService.setMenuList()
            }
            .store(in: &bag)

        setting.$accountMenuList
            .sink { menus in
                DispatchQueue.main.async {
                    self.menuList = self.makeMenuList(menus: menus)
                }
            }
            .store(in: &bag)
    }

    private var userService: UserServiceProtocol {
        services.userService
    }
    
    private var settingsService: SettingsServiceProtocol {
        container.services.settingsService
    }

    private var userState: UserState {
        appState.user
    }
    
    private var setting: Setting {
        appState.setting
    }
    
    func fetchUser() async {
        do {
            try await userService.fetchUser()
        } catch {
            print("user error")
        }
    }
}
