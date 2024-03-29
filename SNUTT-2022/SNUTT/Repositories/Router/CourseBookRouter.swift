//
//  CourseBookRouter.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/19.
//

import Alamofire
import Foundation

enum CourseBookRouter: Router {
    var baseURL: URL { return URL(string: NetworkConfiguration.serverBaseURL + "/course_books")! }
    static let shouldAddToken: Bool = true

    case getCourseBookList
    case getRecentCourseBook
    case getSyllabusURL(year: Int, semester: Int, lecture: LectureDto)

    var method: HTTPMethod {
        switch self {
        case .getCourseBookList, .getSyllabusURL:
            return .get
        case .getRecentCourseBook:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getCourseBookList:
            return ""
        case .getRecentCourseBook:
            return "/recent"
        case .getSyllabusURL:
            return "/official"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .getCourseBookList:
            return nil
        case .getRecentCourseBook:
            return nil
        case let .getSyllabusURL(year, semester, lecture):
            guard let courseNumber = lecture.course_number,
                  let lectureNumber = lecture.lecture_number else { return nil }
            return [
                "year": year,
                "semester": semester,
                "course_number": courseNumber,
                "lecture_number": lectureNumber,
            ]
        }
    }
}
