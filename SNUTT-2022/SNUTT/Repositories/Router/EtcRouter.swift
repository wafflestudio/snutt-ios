//
//  EtcRouter.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/07.
//

import Alamofire
import Foundation

enum EtcRouter: Router {
    var baseURL: URL {
        URL(string: NetworkConfiguration.serverBaseURL)!
    }

    static let shouldAddToken: Bool = true

    case feedback(email: String?, message: String)
    case getColor

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
            return "/colors/vivid_ios"
        }
    }

    var parameters: Parameters? {
        switch self {
        case let .feedback(email, message):
            var ret: [String: Any] = ["message": message]
            if let emailStr = email {
                ret["email"] = emailStr
            }
            return ret
        case .getColor:
            return nil
        }
    }
}
