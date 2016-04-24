//
//  STTimetableRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 13..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

enum STTimetableRouter : URLRequestConvertible {
    
    static let baseURLString = STConfig.sharedInstance.baseURL+"/tables"
    
    case GetTimetableList
    case GetTimetable(String)
    case CreateTimetable(title : String, courseBook : STCourseBook)
    case UpdateTimetable(String, String)
    case DeleteTimetable(String)
    
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
        }
    }
    
    var path: String {
        switch self {
        case .GetTimetableList:
            return ""
        case .GetTimetable(let id):
            return "\(id)"
        case .CreateTimetable:
            return ""
        case .UpdateTimetable(let id, _):
            return "\(id)"
        case .DeleteTimetable(let id):
            return "\(id)"
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: STTimetableRouter.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let token = STDefaults[.token] {
            mutableURLRequest.setValue(token, forHTTPHeaderField: "x-access-token")
        }
        
        switch self {
        case .GetTimetableList:
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: nil).0
        case .GetTimetable:
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: nil).0
        case .CreateTimetable(let title, let courseBook):
            let parameters : [String : AnyObject] = ["title" : title, "year" : courseBook.quarter.year, "semester" : courseBook.quarter.semester.rawValue]
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .UpdateTimetable(_, let title):
            let parameters : [String : AnyObject] = ["title" : title]
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .DeleteTimetable:
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: nil).0
        }
    }
    
}