//
//  BuildingRouter.swift
//  SNUTT
//
//  Created by 최유림 on 2024/04/08.
//

import Alamofire
import Foundation

enum BuildingRouter: Router {
    var baseURL: URL { return URL(string: NetworkConfiguration.serverV1BaseURL + "/buildings")! }
    static let shouldAddToken: Bool = true

    case getBuildingInfo(places: String)

    var method: HTTPMethod {
        switch self {
        case .getBuildingInfo:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getBuildingInfo:
            return ""
        }
    }

    var parameters: Parameters? {
        switch self {
        case let .getBuildingInfo(places):
            return ["places": places]
        }
    }
}
