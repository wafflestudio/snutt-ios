//
//  OnboardViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/03.
//

import SwiftUI
import AuthenticationServices

extension OnboardScene {
    class ViewModel: BaseViewModel, ObservableObject {
        func registerWith(id: String, password: String, email: String) async {
            // TODO: Validation
            do {
                try await services.authService.registerWithId(id: id, password: password, email: email.isEmpty ? nil : email)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
}

extension OnboardScene.ViewModel: FacebookLoginProtocol {
    func handleFacebookToken(fbId: String, fbToken: String) async {
        do {
            try await services.authService.loginWithFacebook(id: fbId, token: fbToken)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }
}


extension OnboardScene.ViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        Task {
            await loginWithApple(successResult: authorization)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
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
            try await services.authService.loginWithApple(token: token)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }
}

