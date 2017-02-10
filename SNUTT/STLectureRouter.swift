//
//  STLectureRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum STLectureRouter : STRouter {
    
    static let baseURLString = STConfig.sharedInstance.baseURL+"/tables"
    static let shouldAddToken: Bool = true
    
    case AddCustomLecture(timetableId: String, lecture: STLecture)
    case AddLecture(timetableId: String, lectureId: String)
    case DeleteLecture(timetableId: String, lecture: STLecture)
    case UpdateLecture(timetableId: String, oldLecture: STLecture, newLecture: STLecture)
    case ResetLecture(timetableId: String, lectureId: String)
    
    var method: Alamofire.Method {
        switch self {
        case .AddCustomLecture:
            return .POST
        case .AddLecture:
            return .POST
        case .DeleteLecture:
            return .DELETE
        case .UpdateLecture, .ResetLecture:
            return .PUT
        }
    }
    
    var path: String {
        switch self {
        case .AddCustomLecture(let timetableId, _ ):
            return "/\(timetableId)/lecture"
        case .AddLecture(let timetableId, let lectureId ):
            return "/\(timetableId)/lecture/\(lectureId)"
        case .DeleteLecture(let timetableId, let lecture ):
            return "/\(timetableId)/lecture/\(lecture.id ?? "")"
        case let .UpdateLecture(timetableId, curLecture, _):
            return "/\(timetableId)/lecture/\(curLecture.id ?? "")"
        case let .ResetLecture(timetableId, lectureId):
            return "/\(timetableId)/lecture/\(lectureId)/reset"
        }
    }
    
    var parameters: [String : AnyObject]? {
        switch self {
        case .AddCustomLecture( _, let lecture):
            var dict = lecture.toDictionary()
            dict.removeValueForKey("id")
            return dict
        case .AddLecture:
            return nil
        case .DeleteLecture:
            return nil
        case let .UpdateLecture(_, oldLecture, newLecture):
            var dict : [String : AnyObject] = [:]
            let oldDict = oldLecture.toDictionary()
            let newDict = newLecture.toDictionary()
            
            for (key, oldVal) in oldDict {
                let newVal = newDict[key]
                if newVal != nil && JSON(oldVal) != JSON(newVal!) {
                    dict[key] = newVal
                }
            }
            return dict
        case .ResetLecture:
            return nil
        }
    }
    
}
