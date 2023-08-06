//
//  ConfigRouter.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/08/05.
//

import Alamofire
import Foundation

enum ConfigRouter: Router {
    var baseURL: URL {
        URL(string: NetworkConfiguration.serverV1BaseURL + "/configs")!
    }

    static var shouldAddToken: Bool { false }

    case getConfigs

    var method: HTTPMethod {
        switch self {
        case .getConfigs:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getConfigs:
            return ""
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getConfigs:
            return nil
        }
    }
}
