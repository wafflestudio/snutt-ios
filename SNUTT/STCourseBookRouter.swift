//
//  STCourseBookRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 8. 31..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

enum STCourseBookRouter : STRouter {
    
    static let baseURLString: String = STConfig.sharedInstance.baseURL + "/course_books"
    static let shouldAddToken: Bool = true
    
    case get
    case recent
    case syllabus(quarter: STQuarter, lecture: STLecture)
    
    
    var method: HTTPMethod {
        switch self {
        case .get, .syllabus:
            return .get
        case .recent:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .get:
            return "/"
        case .recent:
            return "/recent"
        case .syllabus:
            return "/official"
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .get:
            return nil
        case .recent:
            return nil
        case let .syllabus(quarter, lecture):
            if lecture.courseNumber == nil || lecture.lectureNumber == nil {
                return nil
            }
            return [
                "year":quarter.year,
                "semester":quarter.semester.rawValue,
                "course_number":lecture.courseNumber!,
                "lecture_number":lecture.lectureNumber!
            ]
        }
    }
}
