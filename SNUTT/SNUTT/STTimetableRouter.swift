//
//  STTimetableRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 13..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Alamofire
import Foundation

enum STTimetableRouter: STRouter {
    static let baseURLString: String = STConfig.sharedInstance.baseURL + "/tables"
    static let shouldAddToken: Bool = true

    case getTimetableList
    case getTimetable(id: String)
    case createTimetable(title: String, courseBook: STCourseBook)
    case updateTimetable(id: String, title: String)
    case deleteTimetable(id: String)
    case getRecentTimetable()
    case copyTimetable(id: String)
    case updateTheme(id: String, theme: Int)

    var method: HTTPMethod {
        switch self {
        case .getTimetableList:
            return .get
        case .getTimetable:
            return .get
        case .createTimetable:
            return .post
        case .updateTimetable:
            return .put
        case .deleteTimetable:
            return .delete
        case .getRecentTimetable:
            return .get
        case .copyTimetable:
            return .post
        case .updateTheme:
            return .put
        }
    }

    var path: String {
        switch self {
        case .getTimetableList:
            return ""
        case let .getTimetable(id):
            return "/\(id)"
        case .createTimetable:
            return ""
        case let .updateTimetable(id, _):
            return "/\(id)"
        case let .deleteTimetable(id):
            return "/\(id)"
        case .getRecentTimetable:
            return "/recent"
        case let .copyTimetable(id):
            return "/\(id)/copy"
        case let .updateTheme(id, _):
            return "/\(id)/theme"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .getTimetableList:
            return nil
        case .getTimetable:
            return nil
        case let .createTimetable(title, courseBook):
            return ["title": title, "year": courseBook.quarter.year, "semester": courseBook.quarter.semester.rawValue]
        case let .updateTimetable(_, title):
            return ["title": title]
        case .deleteTimetable:
            return nil
        case .getRecentTimetable:
            return nil
        case .copyTimetable:
            return nil
        case let .updateTheme(_, theme):
            return ["theme": theme]
        }
    }
}
