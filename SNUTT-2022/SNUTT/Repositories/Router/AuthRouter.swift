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

    case registerWithId(id: String, password: String, email: String)
    case loginWithId(id: String, password: String)
    case loginWithFacebook(id: String, token: String)
    case loginWithApple(token: String)
    case logout(userId: String, fcmToken: String)

    var method: HTTPMethod {
        switch self {
        case .loginWithId:
            return .post
        case .registerWithId:
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
        case .loginWithId:
            return "/login_local"
        case .registerWithId:
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
        case let .loginWithId(id, password):
            return ["id": id, "password": password]
        case let .registerWithId(id, password, email):
            return ["id": id, "password": password, "email": email]
        case let .loginWithFacebook(id, token):
            return ["fb_id": id, "fb_token": token]
        case let .loginWithApple(token):
            return ["apple_token": token]
        case let .logout(userId, fcmToken):
            return ["user_id": userId, "registration_id": fcmToken]
        }
    }
}
