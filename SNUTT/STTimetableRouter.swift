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
    
    case GetTimetableList
    case GetTimetable(id: String)
    case CreateTimetable(title : String, courseBook : STCourseBook)
    case UpdateTimetable(id: String,title: String)
    case DeleteTimetable(id: String)
    case GetRecentTimetable()
    
    var method: Alamofire.Method {
        switch self {
        case .GetTimetableList:
            return .GET
        case .GetTimetable:
            return .GET
        case .CreateTimetable:
            return .POST
        case .UpdateTimetable:
            return .PUT
        case .DeleteTimetable:
            return .DELETE
        case .GetRecentTimetable:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .GetTimetableList:
            return ""
        case .GetTimetable(let id):
            return "/\(id)"
        case .CreateTimetable:
            return ""
        case .UpdateTimetable(let id, _):
            return "/\(id)"
        case .DeleteTimetable(let id):
            return "/\(id)"
        case .GetRecentTimetable:
            return "/recent"
        }
    }
    
    var parameters: [String : AnyObject]? {
        switch self {
        case .GetTimetableList:
            return nil
        case .GetTimetable:
            return nil
        case .CreateTimetable(let title, let courseBook):
            return ["title" : title, "year" : courseBook.quarter.year, "semester" : courseBook.quarter.semester.rawValue]
        case .UpdateTimetable(_, let title):
            return ["title" : title]
        case .DeleteTimetable:
            return nil
        case .GetRecentTimetable:
            return nil
        }
    }
    
}
