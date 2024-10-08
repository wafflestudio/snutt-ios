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

        func attachLocalId(localId: String, localPassword: String) async -> Bool {
            do {
                try await services.userService.addLocalId(localId: localId, localPassword: localPassword)
                return true
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return false
            }
        }

        func changeNickname(to nickname: String) async -> Bool {
            do {
                try await services.userService.changeNickname(to: nickname)
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
