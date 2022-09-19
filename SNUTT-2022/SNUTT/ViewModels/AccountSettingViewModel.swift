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
    
    var menuList: [[AccountSettings]] {
        var menu: [[AccountSettings]] = []
        menu.append(currentUser?.localId == nil
                    ? [.addLocalId]
                    : [.showLocalId, .changePassword])
        menu.append(currentUser?.fbName == nil
                    ? [.makeFbConnection]
                    : [.showFbName, .deleteFbConnection])
        menu.append([.showEmail])
        menu.append([.deleteAccount])
        return menu
    }

    var currentUser: User? {
        appState.user.current
    }
    
    func fetchUser() async {
        do {
            try await services.userService.fetchUser()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }
    
    func deleteUser() {
        // TODO: implement
    }
}
