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
    case addLocalId(id: String, password: String)
    case addFB(id: String, token: String)
    case detachFB
    case getFB
    case addDevice(id: String)
    case deleteDevice(id: String)
    case deleteUser

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
        case .addFB:
            return .post
        case .detachFB:
            return .delete
        case .getFB:
            return .get
        case .addDevice:
            return .post
        case .deleteDevice:
            return .delete
        case .deleteUser:
            return .delete
        }
    }

    var path: String {
        switch self {
        case .getUser, .editUser:
            return "/info"
        case .changePassword, .addLocalId:
            return "/password"
        case .addFB, .detachFB, .getFB:
            return "/facebook"
        case let .addDevice(id):
            return "/device/\(id)"
        case let .deleteDevice(id):
            return "/device/\(id)"
        case .deleteUser:
            return "/account"
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
        case let .addLocalId(id, password):
            return ["id": id, "password": password]
        case let .addFB(id, token):
            return ["fb_id": id, "fb_token": token]
        case .detachFB:
            return nil
        case .getFB:
            return nil
        case .addDevice:
            return nil
        case .deleteDevice:
            return nil
        case .deleteUser:
            return nil
        }
    }
}
