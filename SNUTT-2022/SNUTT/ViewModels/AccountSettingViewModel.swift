//
//  AccountSettingViewModel.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/01.
//

import Combine
import SwiftUI

class AccountSettingViewModel: BaseViewModel, ObservableObject {
    
    @Published private var _currentUser: User?
    private var bag = Set<AnyCancellable>()
    
    override init(container: DIContainer) {
        super.init(container: container)
        
        // TODO: change this
        appState.user.$current
            .compactMap { $0 }
            .sink { [weak self] user in
                self?._currentUser = user
            }
            .store(in: &bag)
    }
    
    // TODO: implement destinations of each menu
    var menuList: [[SettingsMenu]] {
        var menu: [[SettingsMenu]] = []
        menu.append(currentUser?.localId == nil
                    ? [SettingsMenu(AccountSettings.addLocalId) {
                        AddLocalIdScene(viewModel: AddLocalIdViewModel(container: container))}]
                    : [SettingsMenu(AccountSettings.showLocalId,
                                    content: currentUser?.localId ?? "(없음)"),
                       SettingsMenu(AccountSettings.changePassword)])
        menu.append(currentUser?.fbName == nil
                    ? [SettingsMenu(AccountSettings.makeFbConnection)]
                    : [SettingsMenu(AccountSettings.showFbName,
                                    content: currentUser?.fbName ?? "(없음)"),
                       SettingsMenu(AccountSettings.deleteFbConnection)])
        menu.append([SettingsMenu(AccountSettings.showEmail,
                                  content: currentUser?.email ?? "(없음)")])
        menu.append([SettingsMenu(AccountSettings.deleteAccount, destructive: true)])
        return menu
    }
    
    func fetchUser() async {
        do {
            try await userService.fetchUser()
        } catch {
            print("user error")
        }
    }
    
    private var currentUser: User? {
        appState.user.current
    }

    private var userService: UserServiceProtocol {
        services.userService
    }
}
