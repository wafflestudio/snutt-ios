//
//  KakaoLogin.swift
//  SNUTT
//
//  Created by 이채민 on 6/29/24.
//

import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

protocol KakaoLoginProtocol: BaseViewModelProtocol {
    func performKakaoSignIn()
    func handleKakaoToken(kakaoToken: String) async
}

extension KakaoLoginProtocol {
    func performKakaoSignIn() {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    Task { @MainActor in
                        //                    self.services.globalUIService.presentErrorAlert(error: .NO_KAKAO_TOKEN)
                    }
                    return
                }
                
                guard let accessToken = oauthToken?.accessToken else {
                    Task { @MainActor in
                        //                    self.services.globalUIService.presentErrorAlert(error: .NO_KAKAO_TOKEN)
                    }
                    return
                }
                
                Task { @MainActor in
                    await self.handleKakaoToken(kakaoToken: accessToken)
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    Task { @MainActor in
                        //                    self.services.globalUIService.presentErrorAlert(error: .NO_KAKAO_TOKEN)
                    }
                }
                
                guard let accessToken = oauthToken?.accessToken else {
                    Task { @MainActor in
                        //                    self.services.globalUIService.presentErrorAlert(error: .NO_KAKAO_TOKEN)
                    }
                    return
                }
                
                Task { @MainActor in
                    await self.handleKakaoToken(kakaoToken: accessToken)
                }
            }
        }
    }
}
