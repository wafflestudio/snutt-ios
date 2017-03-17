//
//  STEtcRouter.swift
//  SNUTT
//
//  Created by Rajin on 2017. 2. 10..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

enum STEtcRouter : STRouter {
    
    static let baseURLString : String = STConfig.sharedInstance.baseURL
    static let shouldAddToken: Bool = false
    
    case Feedback(email: String?, message: String)
    case GetColor
    //MARK: STRouter
    
    var method: Alamofire.Method {
        switch self {
        case .Feedback:
            return .POST
        case .GetColor:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .Feedback:
            return "/feedback"
        case .GetColor:
            return "/colors"
        }
    }
    
    var parameters: [String : AnyObject]? {
        switch self {
        case let .Feedback(email, message):
            var ret: [String : AnyObject] = [ "message" : message ]
            if let emailStr = email {
                ret["email"] = emailStr
            }
            return ret
        case .GetColor:
            return nil
        }
    }
    
}
