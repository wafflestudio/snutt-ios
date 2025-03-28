//
//  AuthRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 13..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Alamofire
import Foundation

enum AuthRouter: Router {
    var baseURL: URL {
        URL(string: NetworkConfiguration.serverV1BaseURL + "/auth")!
    }

    static let shouldAddToken: Bool = false

    case registerWithLocalId(localId: String, localPassword: String, email: String)
    case loginWithLocalId(localId: String, localPassword: String)
    case loginWithFacebook(facebookToken: String)
    case loginWithApple(appleToken: String)
    case loginWithGoogle(googleToken: String)
    case loginWithKakao(kakaoToken: String)
    case findLocalId(email: String)
    case getLinkedEmail(localId: String)
    case sendVerificationCode(email: String)
    case checkVerificationCode(localId: String, code: String)
    case resetPassword(localId: String, password: String, code: String)
    case logout(fcmToken: String)

    var method: HTTPMethod {
        switch self {
        case .loginWithLocalId:
            return .post
        case .registerWithLocalId:
            return .post
        case .loginWithFacebook:
            return .post
        case .loginWithApple:
            return .post
        case .loginWithGoogle:
            return .post
        case .loginWithKakao:
            return .post
        case .findLocalId:
            return .post
        case .getLinkedEmail:
            return .post
        case .sendVerificationCode:
            return .post
        case .checkVerificationCode:
            return .post
        case .resetPassword:
            return .post
        case .logout:
            return .post
        }
    }

    var path: String {
        switch self {
        case .loginWithLocalId:
            return "/login_local"
        case .registerWithLocalId:
            return "/register_local"
        case .loginWithFacebook:
            return "/login/facebook"
        case .loginWithApple:
            return "/login/apple"
        case .loginWithGoogle:
            return "/login/google"
        case .loginWithKakao:
            return "/login/kakao"
        case .findLocalId:
            return "/id/find"
        case .getLinkedEmail:
            return "/password/reset/email/check"
        case .sendVerificationCode:
            return "/password/reset/email/send"
        case .checkVerificationCode:
            return "/password/reset/verification/code"
        case .resetPassword:
            return "/password/reset"
        case .logout:
            return "/logout"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case let .loginWithLocalId(localId, localPassword):
            return ["id": localId, "password": localPassword]
        case let .registerWithLocalId(localId, localPassword, email):
            return ["id": localId, "password": localPassword, "email": email]
        case let .loginWithFacebook(facebookToken):
            return ["token": facebookToken]
        case let .loginWithApple(appleToken):
            return ["apple_token": appleToken]
        case let .loginWithGoogle(googleToken):
            return ["token": googleToken]
        case let .loginWithKakao(kakaoToken):
            return ["token": kakaoToken]
        case let .findLocalId(email: email):
            return ["email": email]
        case let .getLinkedEmail(localId: localId):
            return ["user_id": localId]
        case let .sendVerificationCode(email: email):
            return ["email": email]
        case let .checkVerificationCode(localId: localId, code: code):
            return ["user_id": localId, "code": code]
        case let .resetPassword(localId: localId, password: password, code: code):
            return ["user_id": localId, "password": password, "code": code]
        case let .logout(fcmToken):
            return ["registration_id": fcmToken]
        }
    }
}
