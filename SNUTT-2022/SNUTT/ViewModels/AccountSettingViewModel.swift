//
//  AccountSettingViewModel.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/01.
//

import Combine
import SwiftUI

extension AccountSettingScene {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published var currentUser: User?
        private var bag = Set<AnyCancellable>()

        override init(container: DIContainer) {
            super.init(container: container)

            appState.user.$current.assign(to: &$currentUser)
        }

        func unregister() async {
            do {
                try await services.userService.unregister()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func detachFacebook() async {
            do {
                try await services.userService.detachFacebook()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func attachLocalId(id: String, password: String) async {
            do {
                try await services.userService.addLocalId(id: id, password: password)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func changePassword(from oldPassword: String, to newPassword: String) async -> Bool {
            do {
                try await services.userService.changePassword(from: oldPassword, to: newPassword)
                return true
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return false
            }
        }

        func fetchUser() async {
            do {
                try await services.userService.fetchUser()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
}

extension AccountSettingScene.ViewModel: FacebookLoginProtocol {
    func handleFacebookToken(fbId: String, fbToken: String) async {
        do {
            try await services.userService.attachFacebook(fbId: fbId, fbToken: fbToken)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }
}
