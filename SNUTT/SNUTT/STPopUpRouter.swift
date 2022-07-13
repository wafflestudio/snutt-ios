//
//  STPopUpRouter.swift
//  SNUTT
//
//  Created by 최유림 on 2022/06/24.
//  Copyright © 2022 WaffleStudio. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

enum STPopUpRouter: STRouter {
    static let baseURLString = STConfig.sharedInstance.baseURL + "/v1/popups"
    static let shouldAddToken: Bool = true

    case getPopUpList

    var method: HTTPMethod {
        switch self {
        case .getPopUpList:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getPopUpList:
            return ""
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .getPopUpList:
            return nil
        }
    }
}
