//
//  STTagRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 4..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

enum STTagRouter : STRouter {
    
    static let baseURLString = STConfig.sharedInstance.baseURL+"/tags"
    static let shouldAddToken: Bool = true
    
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
    
    var parameters: [String : AnyObject]? {
        return nil
    }
    
}