//
//  IntegrateAccountViewModel.swift
//  SNUTT
//
//  Created by 이채민 on 7/3/24.
//

import Combine
import SwiftUI

extension IntegrateAccountScene {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published var currentUser: User?

        override init(container: DIContainer) {
            super.init(container: container)

            appState.user.$current.assign(to: &$currentUser)
        }

        func detachFacebook() async {
            do {
                try await services.userService.disconnectFacebook()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
}

extension IntegrateAccountScene.ViewModel: FacebookLoginProtocol {
    func handleFacebookToken(fbId: String, fbToken: String) async {
        do {
            try await services.userService.connectFacebook(fbId: fbId, fbToken: fbToken)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }
}
