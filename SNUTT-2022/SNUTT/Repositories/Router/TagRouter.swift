//
//  TagRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 4..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Alamofire
import Foundation

enum TagRouter: Router {
    var baseURL: URL { return URL(string: "https://snutt-api-dev.wafflestudio.com" + "/tags")! }
    static let shouldAddToken: Bool = true

    case getLastUpdateTime(quarter: Quarter)
    case getTags(quarter: Quarter)

    var method: HTTPMethod {
        switch self {
        case .getLastUpdateTime:
            return .get
        case .getTags:
            return .get
        }
    }

    var path: String {
        switch self {
        case let .getLastUpdateTime(quarter):
            return "/\(quarter.year)/\(quarter.semester.rawValue)/update_time"
        case let .getTags(quarter):
            return "/\(quarter.year)/\(quarter.semester.rawValue)"
        }
    }

    var parameters: [String: Any]? {
        return nil
    }
}
