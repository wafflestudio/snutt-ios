//
//  STAuthRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 13..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

enum STAuthRouter : STRouter {
    
    static let baseURLString : String = STConfig.sharedInstance.baseURL+"/auth"
    static let shouldAddToken: Bool = false
    
    case localLogin(id: String, password: String)
    case localRegister(id: String, password: String, email: String?)
    case fbRegister(id: String, token: String)
    case appleRegister(token: String)
    case logOutDevice(userId: String, fcmToken: String)
    
    //MARK: STRouter
    
    var method: HTTPMethod {
        switch self {
        case .localLogin:
            return .post
        case .localRegister:
            return .post
        case .fbRegister:
            return .post
        case .appleRegister:
            return .post
        case .logOutDevice:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .localLogin:
            return "/login_local"
        case .localRegister:
            return "/register_local"
        case .fbRegister:
            return "/login_fb"
        case .appleRegister:
            return "/login_apple"
        case .logOutDevice:
            return "/logout"
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .localLogin(let id, let password):
            return ["id" : id, "password" : password]
        case let .localRegister(id, password, email):
            var ret = ["id" : id, "password" : password]
            if let email = email {
                ret["email"] = email
            }
            return ret
        case let .fbRegister(id, token):
            return ["fb_id" : id, "fb_token" : token]
        case let .appleRegister(token):
            return ["apple_token" : token]
        case let .logOutDevice(userId, fcmToken):
            return ["user_id": userId, "registration_id": fcmToken]
        }
    }
    
}
