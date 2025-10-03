//
//  LectureReminderRouter.swift
//  SNUTT
//
//  Created by 최유림 on 8/30/25.
//

import Alamofire
import Foundation

enum LectureReminderRouter: Router {
    var baseURL: URL {
        URL(string: NetworkConfiguration.serverV1BaseURL + "/tables")!
    }

    case getReminderList(timetableId: String)
    case getReminderState(timetableId: String, lectureId: String)
    case changeReminderState(timetableId: String, lectureId: String, offset: Int)
    case deleteReminder(timetableId: String, lectureId: String)
    
    var method: HTTPMethod {
        switch self {
        case .getReminderList:
            return .get
        case .getReminderState:
            return .get
        case .changeReminderState:
            return .put
        case .deleteReminder:
            return .delete
        }
    }

    var path: String {
        switch self {
        case let .getReminderList(timetableId):
            return "/\(timetableId)/lecture/reminders"
        case let .getReminderState(timetableId, lectureId):
            return "/\(timetableId)/lecture/\(lectureId)/reminder"
        case let .changeReminderState(timetableId, lectureId, _):
            return "/\(timetableId)/lecture/\(lectureId)/reminder"
        case let .deleteReminder(timetableId, lectureId):
            return "/\(timetableId)/lecture/\(lectureId)/reminder"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getReminderList:
            return nil
        case .getReminderState:
            return nil
        case let .changeReminderState(_, _, offset):
            return ["offsetMinutes": offset]
        case .deleteReminder:
            return nil
        }
    }
}
