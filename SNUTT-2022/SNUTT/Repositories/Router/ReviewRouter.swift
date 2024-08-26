//
//  ReviewRouter.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/25.
//

import Alamofire
import Foundation

enum ReviewRouter: Router {
    var baseURL: URL {
        URL(string: NetworkConfiguration.serverV1BaseURL + "/ev")!
    }

    static var shouldAddToken: Bool { true }

    case getEvLectureInfo(lectureId: String)

    var method: HTTPMethod {
        switch self {
        case .getEvLectureInfo:
            return .get
        }
    }

    var path: String {
        switch self {
        case let .getEvLectureInfo(lectureId):
            return "/lectures/\(lectureId)/summary"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getEvLectureInfo:
            return nil
        }
    }
}
