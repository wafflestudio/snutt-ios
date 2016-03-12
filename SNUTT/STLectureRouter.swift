//
//  STLectureRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
//
//  STSearchRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 24..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

enum STLectureRouter : URLRequestConvertible {
    
    static let baseURLString = STConfig.sharedInstance.baseURL+"/tables"
    
    case AddLecture(timetableId: String, lecture: STLecture)
    case DeleteLecture(timetableId: String, lecture: STLecture)
    case UpdateLecture(timetableId: String, lecture: STLecture)
    
    var method: Alamofire.Method {
        switch self {
        case .AddLecture:
            return .POST
        case .DeleteLecture:
            return .DELETE
        case .UpdateLecture:
            return .PUT
        }
    }
    
    var path: String {
        switch self {
        case .AddLecture(let timetableId, _ ):
            return "/\(timetableId)/lecture"
        case .DeleteLecture(let timetableId, _ ):
            return "/\(timetableId)/lecture"
        case .UpdateLecture(let timetableId, _ ):
            return "/\(timetableId)/lecture"
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: STLectureRouter.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let token = STConfig.sharedInstance.token {
            mutableURLRequest.setValue(token, forHTTPHeaderField: "x-access-token")
        }
        
        switch self {
        case .AddLecture( _, let lecture):
            var dict = lecture.toDictionary()
            dict.removeValueForKey("id")
            let parameters : [String: AnyObject] = ["lecture" : dict]
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .DeleteLecture( _, let lecture):
            let parameters : [String: AnyObject] = ["lecture_id": lecture.id]
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .UpdateLecture(let _, let lecture):
            let parameters : [String: AnyObject] = ["lecture" : lecture.toDictionary()]
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        }
    }
    
}