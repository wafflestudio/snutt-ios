//
//  STNotificationRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 8. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Alamofire
import Foundation

enum NotificationRouter: Router {
    var baseURL: URL { return URL(string: "https://snutt-api-dev.wafflestudio.com" + "/notification")! }
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

    var parameters: [String: Any]? {
        switch self {
        case let .notificationList(limit, offset, explicit):
            return ["limit": limit, "offset": offset, "explicit": explicit]
        case .notificationCount:
            return nil
        }
    }
}
