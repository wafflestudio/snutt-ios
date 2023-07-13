//
//  UserRouter.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/18.
//

import Alamofire
import Foundation

enum UserRouter: Router {
    var baseURL: URL { return URL(string: NetworkConfiguration.serverBaseURL + "/user")! }

    static let shouldAddToken: Bool = true

    case getUser
    case editUser(email: String)
    case changePassword(oldPassword: String, newPassword: String)
    case addLocalId(localId: String, localPassword: String)
    case connectFacebook(fbId: String, fbToken: String)
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
        case .editUser:
            return .put
        case .changePassword:
            return .put
        case .addLocalId:
            return .post
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
        case .getUser, .editUser:
            return "/info"
        case .changePassword, .addLocalId:
            return "/password"
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
        case let .editUser(email):
            return ["email": email]
        case let .changePassword(oldPassword, newPassword):
            return ["old_password": oldPassword, "new_password": newPassword]
        case let .addLocalId(localId, localPasword):
            return ["id": localId, "password": localPasword]
        case let .connectFacebook(fbId, fbToken):
            return ["fb_id": fbId, "fb_token": fbToken]
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
