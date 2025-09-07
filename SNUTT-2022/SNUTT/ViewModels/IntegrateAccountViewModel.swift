//
//  IntegrateAccountViewModel.swift
//  SNUTT
//
//  Created by 이채민 on 7/3/24.
//

import AuthenticationServices
import Combine
import SwiftUI

extension IntegrateAccountScene {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published var currentSocialProvider: SocialProvider?

        override init(container: DIContainer) {
            super.init(container: container)

            appState.user.$socialProvider.assign(to: &$currentSocialProvider)
        }

        func disconnectKakao() async {
            do {
                try await services.userService.disconnectKakao()
                try await services.userService.fetchSocialProvider()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func disconnectGoogle() async {
            do {
                try await services.userService.disconnectGoogle()
                try await services.userService.fetchSocialProvider()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func disconnectApple() async {
            do {
                try await services.userService.disconnectApple()
                try await services.userService.fetchSocialProvider()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func disconnectFacebook() async {
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

extension IntegrateAccountScene.ViewModel: AppleLoginProtocol {
    func authorizationController(controller _: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization)
    {
        Task {
            await loginWithApple(successResult: authorization)
        }
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError _: Error) {
        services.globalUIService.presentErrorAlert(error: .SOCIAL_LOGIN_FAILED)
    }

    func performAppleSignIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }

    private func loginWithApple(successResult: ASAuthorization) async {
        guard let credentail = successResult.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credentail.identityToken,
              let token = String(data: tokenData, encoding: .utf8)
        else {
            services.globalUIService.presentErrorAlert(error: .SOCIAL_LOGIN_FAILED)
            return
        }
        Task {
            await handleAppleToken(appleToken: token)
        }
    }

    func handleAppleToken(appleToken: String) async {
        do {
            try await services.userService.connectApple(appleToken: appleToken)
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
