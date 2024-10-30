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
        @Published var currentSocialProvider: SocialProvider?

        override init(container: DIContainer) {
            super.init(container: container)

            appState.user.$socialProvider.assign(to: &$currentSocialProvider)
        }

        func detachKakao() async {
            do {
                try await services.userService.disconnectKakao()
                try await services.userService.fetchSocialProvider()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func detachGoogle() async {
            do {
                try await services.userService.disconnectGoogle()
                try await services.userService.fetchSocialProvider()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func detachFacebook() async {
            do {
                try await services.userService.disconnectFacebook()
                try await services.userService.fetchSocialProvider()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
}

extension IntegrateAccountScene.ViewModel: KakaoLoginProtocol {
    func handleKakaoToken(kakaoToken: String) async {
        do {
            try await services.userService.connectKakao(kakaoToken: kakaoToken)
            try await services.userService.fetchSocialProvider()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }
}

extension IntegrateAccountScene.ViewModel: GoogleLoginProtocol {
    func handleGoogleToken(googleToken: String) async {
        do {
            try await services.userService.connectGoogle(googleToken: googleToken)
            try await services.userService.fetchSocialProvider()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }
}

extension IntegrateAccountScene.ViewModel: FacebookLoginProtocol {
    func handleFacebookToken(facebookId: String, facebookToken: String) async {
        do {
            try await services.userService.connectFacebook(facebookId: facebookId, facebookToken: facebookToken)
            try await services.userService.fetchSocialProvider()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }
}
