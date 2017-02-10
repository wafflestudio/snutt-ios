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
    
    //MARK: STRouter
    
    var method: Alamofire.Method {
        switch self {
        case .Feedback:
            return .POST
        }
    }
    
    var path: String {
        switch self {
        case .Feedback:
            return "/feedback"
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
        }
    }
    
}
