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
            return ""
        case .addLecture(_):
            return "/lectures"
        case .deleteLecture(_):
            return "/lectures"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getLectures:
            return nil
        case let .addLecture(lectureId):
            return ["lectureId": lectureId]
        case let .deleteLecture(lectureId):
            return ["lectureId": lectureId]
        }
    }
}
