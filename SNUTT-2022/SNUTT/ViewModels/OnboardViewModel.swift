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
        func registerWith(id: String, password: String, email: String) async {
            // TODO: Validation
            do {
                try await services.authService.registerWithLocalId(localId: id, localPassword: password, email: email)
            } catch {
                await services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
}

extension OnboardScene.ViewModel: FacebookLoginProtocol {
    func handleFacebookToken(fbId: String, fbToken: String) async {
        do {
            try await services.authService.loginWithFacebook(fbId: fbId, fbToken: fbToken)
        } catch {
            await services.globalUIService.presentErrorAlert(error: error)
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
        Task {
            await services.globalUIService.presentErrorAlert(error: .WRONG_APPLE_TOKEN)
        }
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
            await services.globalUIService.presentErrorAlert(error: .WRONG_APPLE_TOKEN)
            return
        }
        do {
            try await services.authService.loginWithApple(appleToken: token)
        } catch {
            await services.globalUIService.presentErrorAlert(error: error)
        }
    }
}
