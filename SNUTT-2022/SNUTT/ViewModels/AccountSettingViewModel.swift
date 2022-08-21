//
//  AccountSettingViewModel.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/01.
//

import SwiftUI
import Combine

class AccountSettingViewModel: BaseViewModel, ObservableObject {

    private var bag = Set<AnyCancellable>()
    
    @Published var menuList: [[Menu]] = []
    
    override init(container: DIContainer) {
        super.init(container: container)

        userState.$current
            .sink { user in
                self.settingsService.updateAccountMenuList()
            }
            .store(in: &bag)

        setting.$accountMenuList
            .sink { menuList in
                DispatchQueue.main.async {
                    self.menuList = self.setMenuList(menuList)
                }
            }
            .store(in: &bag)
    }
    
    private func setMenuList(_ titles: [[AccountSettings]]) -> [[Menu]] {
        var menuList: [[Menu]] = []
        for section in titles {
            var rows: [Menu] = []
            for title in section {
                rows.append(makeMenu(title))
            }
            menuList.append(rows)
        }
        return menuList
    }
    
    private func makeMenu(_ type: AccountSettings) -> Menu {
        switch(type) {
        case .addLocalId:
            return Menu(AccountSettings.addLocalId) {
                AddLocalIdScene(viewModel: AddLocalIdViewModel(container: container))
            }
        case .showLocalId:
            return Menu(AccountSettings.showLocalId, userState.current?.localId ?? "(없음)")
        case .changePassword:
            return Menu(AccountSettings.changePassword)
        case .makeFbConnection:
            return Menu(AccountSettings.makeFbConnection)
        case .showFbName:
            return Menu(AccountSettings.showFbName, userState.current?.fbName ?? "(없음)")
        case .deleteFbConnection:
            return Menu(AccountSettings.deleteFbConnection)
        case .showEmail:
            return Menu(AccountSettings.showEmail, self.appState.user.current?.email ?? "(없음)")
        case .deleteAccount:
            return Menu(AccountSettings.deleteAccount, destructive: true)
        }
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

