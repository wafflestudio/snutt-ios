//
//  STAuthRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 13..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

enum STAuthRouter : URLRequestConvertible {
    
    static let baseURLString = STConfig.sharedInstance.baseURL+"/auth"
    
    case LocalLogin(String, String)
    
    var method: Alamofire.Method {
        switch self {
        case .LocalLogin:
            return .POST
        }
    }
    
    var path: String {
        switch self {
        case .LocalLogin:
            return "/login_local"
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: STAuthRouter.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        switch self {
        case .LocalLogin(let id, let password):
            let parameters = ["id" : id, "password" : password]
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        }
    }
    
}