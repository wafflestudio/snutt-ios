//
//  UserRouter.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/18.
//

import Alamofire
import Foundation

enum UserRouter: Router {
    var baseURL: URL {
        switch self {
        case .getUser, .getSocialProvider, .changeNickname:
            return URL(string: NetworkConfiguration.serverV1BaseURL + "/users")!
        default:
            return URL(string: NetworkConfiguration.serverV1BaseURL + "/user")!
        }
    }

    static let shouldAddToken: Bool = true

    case getUser
    case getSocialProvider
    case changeNickname(nickname: String)
    case changePassword(oldPassword: String, newPassword: String)
    case addLocalId(localId: String, localPassword: String)
    case connectKakao(kakaoToken: String)
    case disconnectKakao
    case connectGoogle(googleToken: String)
    case disconnectGoogle
    case connectFacebook(facebookId: String, facebookToken: String)
    case disconnectFacebook
    case getFB
    case addDevice(fcmToken: String)
    case deleteDevice(fcmToken: String)
    case deleteUser
    case sendVerificationCode(email: String)
    case submitVerificationCode(code: String)

    var method: HTTPMethod {
        switch self {
        case .getUser:
            return .get
        case .getSocialProvider:
            return .get
        case .changeNickname:
            return .patch
        case .changePassword:
            return .put
        case .addLocalId:
            return .post
        case .connectKakao:
            return .post
        case .disconnectKakao:
            return .delete
        case .connectGoogle:
            return .post
        case .disconnectGoogle:
            return .delete
        case .connectFacebook:
            return .post
        case .disconnectFacebook:
            return .delete
        case .getFB:
            return .get
        case .addDevice:
            return .post
        case .deleteDevice:
            return .delete
        case .deleteUser:
            return .delete
        case .sendVerificationCode:
            return .post
        case .submitVerificationCode:
            return .post
        }
    }

    var path: String {
        switch self {
        case .getUser, .changeNickname:
            return "/me"
        case .getSocialProvider:
            return "/me/social_providers"
        case .changePassword, .addLocalId:
            return "/password"
        case .connectKakao, .disconnectKakao:
            return "/kakao"
        case .connectGoogle, .disconnectGoogle:
            return "/google"
        case .connectFacebook, .disconnectFacebook, .getFB:
            return "/facebook"
        case let .addDevice(fcmToken):
            return "/device/\(fcmToken)"
        case let .deleteDevice(fcmToken):
            return "/device/\(fcmToken)"
        case .deleteUser:
            return "/account"
        case .sendVerificationCode:
            return "/email/verification"
        case .submitVerificationCode:
            return "/email/verification/code"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .getUser:
            return nil
        case .getSocialProvider:
            return nil
        case let .changeNickname(nickname):
            return ["nickname": nickname]
        case let .changePassword(oldPassword, newPassword):
            return ["old_password": oldPassword, "new_password": newPassword]
        case let .addLocalId(localId, localPasword):
            return ["id": localId, "password": localPasword]
        case let .connectKakao(kakaoToken):
            return ["token": kakaoToken]
        case .disconnectKakao:
            return nil
        case let .connectGoogle(googleToken):
            return ["token": googleToken]
        case .disconnectGoogle:
            return nil
        case let .connectFacebook(facebookId, facebookToken):
            return ["fb_id": facebookId, "fb_token": facebookToken]
        case .disconnectFacebook:
            return nil
        case .getFB:
            return nil
        case .addDevice:
            return nil
        case .deleteDevice:
            return nil
        case .deleteUser:
            return nil
        case let .sendVerificationCode(email):
            return ["email": email]
        case let .submitVerificationCode(code):
            return ["code": code]
        }
    }
}
