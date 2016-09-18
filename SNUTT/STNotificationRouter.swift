//
//  STNotificationRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 8. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum STNotificationRouter : STRouter {
    
    static let baseURLString = STConfig.sharedInstance.baseURL+"/notification"
    static let shouldAddToken: Bool = true
    
    case NotificationList(limit: Int, offset: Int, explicit: Bool)
    case NotificationCount
    
    var method: Alamofire.Method {
        switch self {
        case .NotificationList:
            return .GET
        case .NotificationCount:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .NotificationList:
            return ""
        case .NotificationCount:
            return "/count"
        }
    }
    
    var parameters: [String : AnyObject]? {
        switch self {
        case let .NotificationList(limit, offset, explicit):
            var dict : [String : AnyObject] = ["limit" : limit, "offset" : offset]
            if explicit {
                dict["explicit"] = true
            }
            return dict
        case .NotificationCount:
            return nil
        }
    }
}