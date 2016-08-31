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
    case AttachFB(id: String, token: String)
    case DetachFB
    case GetFB
    
    var method: Alamofire.Method {
        switch self {
        case .GetUser:
            return .GET
        case .AttachFB:
            return .POST
        case .DetachFB:
            return .POST
        case .GetFB:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .GetUser:
            return "info"
        case .AttachFB:
            return "attach_fb"
        case .DetachFB:
            return "detach_fb"
        case .GetFB:
            return "status_fb"
        }
    }
    
    var parameters: [String : AnyObject]? {
        switch self {
        case .GetUser:
            return nil
        case let .AttachFB(id, token):
            return ["fb_id": id, "fb_token": token]
        case .DetachFB:
            return nil
        case .GetFB:
            return nil
        }
    }
}