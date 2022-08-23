//
//  AccountSettingViewModel.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/01.
//

import Combine
import SwiftUI

class AccountSettingViewModel: BaseViewModel, ObservableObject {
    private var bag = Set<AnyCancellable>()

    @Published var menuList: [[SettingsMenu]] = []

    override init(container: DIContainer) {
        super.init(container: container)

        userState.$current
            .sink { _ in
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

    private func setMenuList(_ titles: [[AccountSettings]]) -> [[SettingsMenu]] {
        var menuList: [[SettingsMenu]] = []
        for section in titles {
            var rows: [SettingsMenu] = []
            for title in section {
                rows.append(makeMenu(title))
            }
            menuList.append(rows)
        }
        return menuList
    }

    private func makeMenu(_ type: AccountSettings) -> SettingsMenu {
        switch type {
        case .addLocalId:
            return SettingsMenu(AccountSettings.addLocalId) {
                AddLocalIdScene(viewModel: AddLocalIdViewModel(container: container))
            }
        case .showLocalId:
            return SettingsMenu(AccountSettings.showLocalId, userState.current?.localId ?? "(없음)")
        case .changePassword:
            return SettingsMenu(AccountSettings.changePassword)
        case .makeFbConnection:
            return SettingsMenu(AccountSettings.makeFbConnection)
        case .showFbName:
            return SettingsMenu(AccountSettings.showFbName, userState.current?.fbName ?? "(없음)")
        case .deleteFbConnection:
            return SettingsMenu(AccountSettings.deleteFbConnection)
        case .showEmail:
            return SettingsMenu(AccountSettings.showEmail, appState.user.current?.email ?? "(없음)")
        case .deleteAccount:
            return SettingsMenu(AccountSettings.deleteAccount, destructive: true)
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
