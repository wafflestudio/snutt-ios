//
//  STTimetableRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 13..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

enum STTimetableRouter : STRouter {
    
    static let baseURLString : String = STConfig.sharedInstance.baseURL+"/tables"
    static let shouldAddToken: Bool = true
    
    case getTimetableList
    case getTimetable(id: String)
    case createTimetable(title : String, courseBook : STCourseBook)
    case updateTimetable(id: String,title: String)
    case deleteTimetable(id: String)
    case getRecentTimetable()
    case copyTimetable(id: String)
    
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
        }
    }
    
    var path: String {
        switch self {
        case .getTimetableList:
            return ""
        case .getTimetable(let id):
            return "/\(id)"
        case .createTimetable:
            return ""
        case .updateTimetable(let id, _):
            return "/\(id)"
        case .deleteTimetable(let id):
            return "/\(id)"
        case .getRecentTimetable:
            return "/recent"
        case .copyTimetable(let id):
            return "/\(id)/copy"
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .getTimetableList:
            return nil
        case .getTimetable:
            return nil
        case .createTimetable(let title, let courseBook):
            return ["title" : title, "year" : courseBook.quarter.year, "semester" : courseBook.quarter.semester.rawValue]
        case .updateTimetable(_, let title):
            return ["title" : title]
        case .deleteTimetable:
            return nil
        case .getRecentTimetable:
            return nil
        case .copyTimetable:
            return nil
        }
    }
    
}
