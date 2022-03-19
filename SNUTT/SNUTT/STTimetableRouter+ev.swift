//
//  STTimetableRouter+ev.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/02/06.
//  Copyright © 2022 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

// for SNUTT-ev api
enum STEVRouter : STRouter {
    static let baseURLString : String = STConfig.sharedInstance.baseURL+"/ev-service/v1"
    static let shouldAddToken: Bool = true
    
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
    
    var parameters: [String : Any]? {
        switch self {
        case .getReviewId(let courseNumber, let instructor):
            return ["course_number": courseNumber, "instructor": instructor]
        }
    }
    
}
