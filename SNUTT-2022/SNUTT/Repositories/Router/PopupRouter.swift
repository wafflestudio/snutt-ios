//
//  PopupRouter.swift
//  SNUTT
//
//  Created by 최유림 on 2022/11/04.
//

import Alamofire
import Foundation

enum PopupRouter: Router {
    var baseURL: URL {
        URL(string: NetworkConfiguration.serverBaseURL + "/v1/popups")!
    }

    static let shouldAddToken: Bool = true

    case getPopupList

    var method: HTTPMethod {
        switch self {
        case .getPopupList:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getPopupList:
            return ""
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getPopupList:
            return nil
        }
    }
}
