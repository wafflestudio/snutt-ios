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
