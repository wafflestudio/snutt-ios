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
        URL(string: NetworkConfiguration.serverBaseURL + "/ev-service/v1")!
    }

    static var shouldAddToken: Bool { true }

    case getReviewId(courseNumber: String, instructor: String)

    var method: HTTPMethod {
        switch self {
        case .getReviewId:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getReviewId:
            return "/lectures/id"
        }
    }

    var parameters: Parameters? {
        switch self {
        case let .getReviewId(courseNumber, instructor):
            return ["course_number": courseNumber, "instructor": instructor]
        }
    }
}
