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
    
    case feedback(email: String?, message: String)
    case getColor
    //MARK: STRouter
    
    var method: HTTPMethod {
        switch self {
        case .feedback:
            return .post
        case .getColor:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .feedback:
            return "/feedback"
        case .getColor:
            return "/colors"
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case let .feedback(email, message):
            var ret: [String : Any] = [ "message" : message ]
            if let emailStr = email {
                ret["email"] = emailStr
            }
            return ret
        case .getColor:
            return nil
        }
    }
    
}
