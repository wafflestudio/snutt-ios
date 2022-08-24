//
//  UserRouter.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/18.
//

import Alamofire
import Foundation

enum UserRouter: Router {
    var baseURL: URL { return URL(string: NetworkConfiguration.serverBaseURL + "/user")! }

    static let shouldAddToken: Bool = true

    case getUser

    var method: HTTPMethod {
        switch self {
        case .getUser:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getUser:
            return "/info"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getUser:
            return nil
        }
    }
}
