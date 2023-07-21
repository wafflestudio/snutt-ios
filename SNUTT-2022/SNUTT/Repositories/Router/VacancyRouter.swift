//
//  VacancyRouter.swift
//  SNUTT
//
//  Created by user on 2023/07/22.
//

import Alamofire
import Foundation

enum VacancyRouter: Router {
    var baseURL: URL { return URL(string: NetworkConfiguration.serverV1BaseURL + "/vacancy-notifications")! }

    case getLectures
    case addLecture(lectureId: String)
    case deleteLecture(lectureId: String)

    var method: HTTPMethod {
        switch self {
        case .getLectures:
            return .get
        case .addLecture(_):
            return .post
        case .deleteLecture(_):
            return .delete
        }
    }

    var path: String {
        switch self {
        case .getLectures:
            return "/lectures"
        case let .addLecture(lectureId):
            return "/lectures/\(lectureId)"
        case let .deleteLecture(lectureId):
            return "/lectures/\(lectureId)"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getLectures:
            return nil
        case .addLecture(_):
            return nil
        case .deleteLecture(_):
            return nil
        }
    }
}
