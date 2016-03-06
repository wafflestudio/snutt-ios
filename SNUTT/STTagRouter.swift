//
//  STTagRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 4..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

enum STTagRouter : URLRequestConvertible {
    
    static let baseURLString = STConfig.sharedInstance.baseURL+"/tags"
    
    case UpdateTime(quarter : STQuarter)
    case Get(quarter : STQuarter)
    
    var method: Alamofire.Method {
        switch self {
        case .UpdateTime:
            return .GET
        case .Get:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .UpdateTime(let quarter):
            return "/\(quarter.year)/\(quarter.semester.rawValue)/update_time"
        case .Get(let quarter):
            return "/\(quarter.year)/\(quarter.semester.rawValue)"
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: STTagRouter.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: nil).0
    }
    
}