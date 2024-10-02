//
//  OnboardViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/03.
//

import AuthenticationServices
import SwiftUI

extension OnboardScene {
    class ViewModel: BaseViewModel, ObservableObject {
        private func handleSocialLoginError(_ error: Error) {
            let socialProviderMapping: [String: String] = [
                "LOCAL": "SNUTT",
                "FACEBOOK": "페이스북",
                "APPLE": "애플",
                "GOOGLE": "구글",
                "KAKAO": "카카오",
            ]

            if let stError = error as? STError, let underlyingError = stError.underlyingError {
                let socialProviderKey = underlyingError["socialProvider"]
                let socialProviderName = socialProviderMapping[socialProviderKey ?? ""] ?? socialProviderKey
                let updatedContent = stError.content + "\n\(socialProviderName ?? "") 계정으로 시도해 보세요."
                let newError = STError(stError.code, content: updatedContent, detail: nil)
                services.globalUIService.presentErrorAlert(error: newError)
            } else {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func registerWith(id: String, password: String, email: String) async -> Bool {
            // TODO: Validation
            do {
                try await services.authService.registerWithLocalId(localId: id, localPassword: password, email: email)
                return true
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return false
            }
        }

        func sendFeedback(email: String, message: String) async -> Bool {
            if !Validation.check(email: email) {
                services.globalUIService.presentErrorAlert(error: .INVALID_EMAIL)
                return false
            }
            do {
                try await services.etcService.sendFeedback(email: email, message: message)
                return true
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return false
            }
        }

        func sendVerificationCode(email: String) async -> Bool {
            do {
                try await services.userService.sendVerificationCode(email: email)
                return true
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return false
            }
        }

        func submitVerificationCode(code: String) async -> Bool {
            do {
                try await services.userService.submitVerificationCode(code: code)
                return true
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return false
            }
        }
    }
}

extension OnboardScene.ViewModel: FacebookLoginProtocol {
    func handleFacebookToken(fbId _: String, fbToken: String) async {
        do {
            try await services.authService.loginWithFacebook(facebookToken: fbToken)
        } catch {
            handleSocialLoginError(error)
        }
    }
}

extension OnboardScene.ViewModel: GoogleLoginProtocol {
    func handleGoogleToken(googleToken: String) async {
        do {
            try await services.authService.loginWithGoogle(googleToken: googleToken)
        } catch {
            handleSocialLoginError(error)
        }
    }
}

extension OnboardScene.ViewModel: KakaoLoginProtocol {
    func handleKakaoToken(kakaoToken: String) async {
        do {
            try await services.authService.loginWithKakao(kakaoToken: kakaoToken)
        } catch {
            handleSocialLoginError(error)
        }
    }
}

extension OnboardScene.ViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller _: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization)
    {
        Task {
            await loginWithApple(successResult: authorization)
        }
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError _: Error) {
        services.globalUIService.presentErrorAlert(error: .WRONG_APPLE_TOKEN)
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
            services.globalUIService.presentErrorAlert(error: .WRONG_APPLE_TOKEN)
            return
        }
        do {
            try await services.authService.loginWithApple(appleToken: token)
        } catch {
            handleSocialLoginError(error)
        }
    }
}
