//
//  SemesterRouter.swift
//  SNUTT
//
//  Created by 최유림 on 10/3/25.
//

import Alamofire
import Foundation

enum SemesterRouter: Router {
    var baseURL: URL {
        URL(string: NetworkConfiguration.serverV1BaseURL + "/semesters")!
    }

    case getSemesterStatus
    
    var method: HTTPMethod {
        switch self {
        case .getSemesterStatus:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getSemesterStatus:
            return "/status"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getSemesterStatus:
            return nil
        }
    }
}
