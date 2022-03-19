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
    
    case notificationList(limit: Int, offset: Int, explicit: Bool)
    case notificationCount
    
    var method: HTTPMethod {
        switch self {
        case .notificationList:
            return .get
        case .notificationCount:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .notificationList:
            return ""
        case .notificationCount:
            return "/count"
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case let .notificationList(limit, offset, explicit):
            var dict : [String : Any] = ["limit" : limit, "offset" : offset]
            if explicit {
                dict["explicit"] = true
            }
            return dict
        case .notificationCount:
            return nil
        }
    }
}
