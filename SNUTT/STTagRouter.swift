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
    
    case updateTime(quarter : STQuarter)
    case get(quarter : STQuarter)
    
    var method: HTTPMethod {
        switch self {
        case .updateTime:
            return .get
        case .get:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .updateTime(let quarter):
            return "/\(quarter.year)/\(quarter.semester.rawValue)/update_time"
        case .get(let quarter):
            return "/\(quarter.year)/\(quarter.semester.rawValue)"
        }
    }
    
    var parameters: [String : Any]? {
        return nil
    }
    
}
