//
//  STAuthRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 13..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Alamofire
import Foundation

enum AuthRouter: Router {
    var baseURL: URL { return URL(string: NetworkConfiguration.serverBaseURL + "/auth")! }
    static let shouldAddToken: Bool = false

    case registerWithLocalId(localId: String, localPassword: String, email: String)
    case loginWithLocalId(localId: String, localPassword: String)
    case loginWithFacebook(fbId: String, fbToken: String)
    case loginWithApple(appleToken: String)
    case logout(userId: String, fcmToken: String)

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
            return "/login_fb"
        case .loginWithApple:
            return "/login_apple"
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
        case let .loginWithFacebook(fbId, fbToken):
            return ["fb_id": fbId, "fb_token": fbToken]
        case let .loginWithApple(appleToken):
            return ["apple_token": appleToken]
        case let .logout(userId, fcmToken):
            return ["user_id": userId, "registration_id": fcmToken]
        }
    }
}
