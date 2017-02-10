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
    
    case Get
    case Recent
    case Syllabus(quarter: STQuarter, lecture: STLecture)
    
    
    var method: Alamofire.Method {
        switch self {
        case .Get, .Syllabus:
            return .GET
        case .Recent:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .Get:
            return "/"
        case .Recent:
            return "recent"
        case .Syllabus:
            return "official"
        }
    }
    
    var parameters: [String : AnyObject]? {
        switch self {
        case .Get:
            return nil
        case .Recent:
            return nil
        case let .Syllabus(quarter, lecture):
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
