//
//  STUserRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 8. 24..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

enum STUserRouter : STRouter {
    
    static let baseURLString: String = STConfig.sharedInstance.baseURL + "/user"
    static let shouldAddToken: Bool = true
    
    case GetUser
    case EditUser(email: String)
    case ChangePassword(password: String)
    case AddLocalId(id: String, password: String)
    case AddFB(id: String, token: String)
    case DetachFB
    case GetFB
    case AddDevice(id: String)
    case DeleteUser
    
    var method: Alamofire.Method {
        switch self {
        case .GetUser:
            return .GET
        case .EditUser:
            return .POST
        case .ChangePassword:
            return .PUT
        case .AddLocalId:
            return .POST
        case .AddFB:
            return .POST
        case .DetachFB:
            return .DELETE
        case .GetFB:
            return .GET
        case .AddDevice:
            return .POST
        case .DeleteUser:
            return .DELETE
        }
    }
    
    var path: String {
        switch self {
        case .GetUser, .EditUser:
            return "/info"
        case .ChangePassword, .AddLocalId:
            return "/password"
        case .AddFB, .DetachFB, .GetFB:
            return "/facebook"
        case .AddDevice:
            return "/device"
        case .DeleteUser:
            return "/account"
        }
    }
    
    var parameters: [String : AnyObject]? {
        
        switch self {
        case .GetUser:
            return nil
        case let .EditUser(email):
            return ["email" : email]
        case let .ChangePassword(password):
            return ["password" : password]
        case let .AddLocalId(id, password):
            return ["id": id, "password" : password]
        case let .AddFB(id, token):
            return ["fb_id": id, "fb_token": token]
        case .DetachFB:
            return nil
        case .GetFB:
            return nil
        case let .AddDevice(id):
            return ["registration_id": id]
        case .DeleteUser:
            return nil
        }
    }
}