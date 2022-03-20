//
//  STLectureRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

enum STLectureRouter: STRouter {
    static let baseURLString = STConfig.sharedInstance.baseURL + "/tables"
    static let shouldAddToken: Bool = true

    case addCustomLecture(timetableId: String, lecture: STLecture)
    case addLecture(timetableId: String, lectureId: String)
    case deleteLecture(timetableId: String, lecture: STLecture)
    case updateLecture(timetableId: String, oldLecture: STLecture, newLecture: STLecture)
    case resetLecture(timetableId: String, lectureId: String)

    var method: HTTPMethod {
        switch self {
        case .addCustomLecture:
            return .post
        case .addLecture:
            return .post
        case .deleteLecture:
            return .delete
        case .updateLecture, .resetLecture:
            return .put
        }
    }

    var path: String {
        switch self {
        case let .addCustomLecture(timetableId, _):
            return "/\(timetableId)/lecture"
        case let .addLecture(timetableId, lectureId):
            return "/\(timetableId)/lecture/\(lectureId)"
        case let .deleteLecture(timetableId, lecture):
            return "/\(timetableId)/lecture/\(lecture.id ?? "")"
        case let .updateLecture(timetableId, curLecture, _):
            return "/\(timetableId)/lecture/\(curLecture.id ?? "")"
        case let .resetLecture(timetableId, lectureId):
            return "/\(timetableId)/lecture/\(lectureId)/reset"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case let .addCustomLecture(_, lecture):
            var dict = lecture.toDictionary()
            dict.removeValue(forKey: "id")
            return dict
        case .addLecture:
            return nil
        case .deleteLecture:
            return nil
        case let .updateLecture(_, oldLecture, newLecture):
            var dict: [String: Any] = [:]
            let oldDict = oldLecture.toDictionary()
            let newDict = newLecture.toDictionary()
            for (key, oldVal) in oldDict {
                let newVal = newDict[key]
                if newVal != nil, JSON(oldVal) != JSON(newVal!) {
                    dict[key] = newVal
                }
            }
            for (key, newVal) in newDict {
                let oldVal = oldDict[key]
                if oldVal == nil || JSON(oldVal!) != JSON(newVal) {
                    dict[key] = newVal
                }
            }
            return dict
        case .resetLecture:
            return nil
        }
    }
}
