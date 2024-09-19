//
//  GoogleLogin.swift
//  SNUTT
//
//  Created by 이채민 on 6/29/24.
//

import GoogleSignIn

protocol GoogleLoginProtocol: BaseViewModelProtocol {
    func performGoogleSignIn()
    func handleGoogleToken(googleToken: String) async
}

extension GoogleLoginProtocol {
    func performGoogleSignIn() {
        guard let rootViewController = UIApplication.shared.connectedScenes
            .flatMap({ ($0 as? UIWindowScene)?.windows ?? [] })
            .first(where: { $0.isKeyWindow })?.rootViewController
        else {
            Task { @MainActor in
                self.services.globalUIService.presentErrorAlert(error: .NO_GOOGLE_TOKEN)
            }
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { user, error in
            if error != nil {
                Task { @MainActor in
                    self.services.globalUIService.presentErrorAlert(error: .NO_GOOGLE_TOKEN)
                }
                return
            }

            guard let userData = user?.user else {
                Task { @MainActor in
                    self.services.globalUIService.presentErrorAlert(error: .NO_GOOGLE_TOKEN)
                }
                return
            }

            let accessToken = userData.accessToken.tokenString

            Task { @MainActor in
                await self.handleGoogleToken(googleToken: accessToken)
            }
        }
    }
}
