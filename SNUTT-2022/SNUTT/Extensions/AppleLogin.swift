//
//  AppleLogin.swift
//  SNUTT
//
//  Created by 이채민 on 1/17/25.
//

import AuthenticationServices

protocol AppleLoginProtocol: BaseViewModelProtocol, ASAuthorizationControllerDelegate {
    func performAppleSignIn()
    func handleAppleToken(appleToken: String) async
}

extension AppleLoginProtocol {
    func authorizationController(controller _: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization)
    {
        Task {
            await loginWithApple(successResult: authorization)
        }
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError _: Error) {
        Task { @MainActor in
            self.services.globalUIService.presentErrorAlert(error: .WRONG_APPLE_TOKEN)
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
        print("try login")
        guard let credentail = successResult.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credentail.identityToken,
              let token = String(data: tokenData, encoding: .utf8)
        else {
            Task { @MainActor in
                self.services.globalUIService.presentErrorAlert(error: .WRONG_APPLE_TOKEN)
            }
            return
        }
        Task { @MainActor in
            await self.handleAppleToken(appleToken: token)
        }
    }
}
