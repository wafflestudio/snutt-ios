//
//  FacebookLogin.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/03.
//

import FacebookLogin

protocol FacebookLoginProtocol: BaseViewModelProtocol {
    func performFacebookSignIn()
    func handleFacebookToken(fbId: String, fbToken: String) async
}

extension FacebookLoginProtocol {
    func performFacebookSignIn() {
        LoginManager().logIn(permissions: [Permission.publicProfile.name], from: nil) { result, error in

            if error != nil {
                self.services.globalUIService.presentErrorAlert(error: .NO_FB_ID_OR_TOKEN)
                return
            }

            guard let result = result else {
                self.services.globalUIService.presentErrorAlert(error: .NO_FB_ID_OR_TOKEN)
                return
            }

            if result.isCancelled {
                return
            }

            guard let fbUserId = result.token?.userID,
                  let fbToken = result.token?.tokenString
            else {
                self.services.globalUIService.presentErrorAlert(error: .NO_FB_ID_OR_TOKEN)
                return
            }

            Task {
                await self.handleFacebookToken(fbId: fbUserId, fbToken: fbToken)
            }
        }
    }
}
