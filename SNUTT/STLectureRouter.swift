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
    
    case AddLecture(timetableId: String, lecture: STLecture)
    case DeleteLecture(timetableId: String, lecture: STLecture)
    case UpdateLecture(timetableId: String, oldLecture: STLecture, newLecture: STLecture)
    
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
        case .DeleteLecture(let timetableId, let lecture ):
            return "/\(timetableId)/lecture/\(lecture.id ?? "")"
        case let .UpdateLecture(timetableId, curLecture, _):
            return "/\(timetableId)/lecture/\(curLecture.id ?? "")"
        }
    }
    
    var parameters: [String : AnyObject]? {
        switch self {
        case .AddLecture( _, let lecture):
            var dict = lecture.toDictionary()
            dict.removeValueForKey("id")
            return dict
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
        }
    }
    
}
