//
//  FacebookLogin.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/03.
//

import FacebookLogin

protocol FacebookLoginProtocol: BaseViewModelProtocol {
    func performFacebookSignIn()
    func handleFacebookToken(facebookId: String, facebookToken: String) async
}

extension FacebookLoginProtocol {
    func performFacebookSignIn() {
        LoginManager().logIn(permissions: [Permission.publicProfile.name], from: nil) { result, error in

            if error != nil {
                Task { @MainActor in
                    self.services.globalUIService.presentErrorAlert(error: .NO_FB_ID_OR_TOKEN)
                }
                return
            }

            guard let result = result else {
                Task { @MainActor in
                    self.services.globalUIService.presentErrorAlert(error: .NO_FB_ID_OR_TOKEN)
                }
                return
            }

            if result.isCancelled {
                return
            }

            guard let fbUserId = result.token?.userID,
                  let fbToken = result.token?.tokenString
            else {
                Task { @MainActor in
                    self.services.globalUIService.presentErrorAlert(error: .NO_FB_ID_OR_TOKEN)
                }
                return
            }

            Task { @MainActor in
                await self.handleFacebookToken(facebookId: fbUserId, facebookToken: fbToken)
            }
        }
    }
}
