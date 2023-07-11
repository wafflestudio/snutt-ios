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

        override init(container: DIContainer) {
            super.init(container: container)

            appState.user.$current.assign(to: &$currentUser)
        }

        func deleteUser() async {
            do {
                try await services.userService.deleteUser()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func detachFacebook() async {
            do {
                try await services.userService.disconnectFacebook()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func attachLocalId(localId: String, localPassword: String) async -> Bool {
            do {
                try await services.userService.addLocalId(localId: localId, localPassword: localPassword)
                return true
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return false
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
    }
}

extension AccountSettingScene.ViewModel: FacebookLoginProtocol {
    func handleFacebookToken(fbId: String, fbToken: String) async {
        do {
            try await services.userService.connectFacebook(fbId: fbId, fbToken: fbToken)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }
}
