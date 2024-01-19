//
//  TimetableRouter.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/07/08.
//

import Alamofire
import Foundation

enum TimetableRouter: Router {
    var baseURL: URL {
        return URL(string: NetworkConfiguration.serverV1BaseURL + "/tables")!
    }

    case getTimetableList
    case getTimetable(id: String)
    case createTimetable(title: String, year: Int, semester: Int)
    case updateTimetable(id: String, title: String)
    case setPrimaryTimetable(id: String)
    case unsetPrimaryTimetable(id: String)
    case deleteTimetable(id: String)
    case getRecentTimetable
    case copyTimetable(id: String)
    case updateTheme(id: String, theme: Int?, themeId: String)

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
        case .setPrimaryTimetable:
            return .post
        case .unsetPrimaryTimetable:
            return .delete
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
        case let .setPrimaryTimetable(id):
            return "/\(id)/primary"
        case let .unsetPrimaryTimetable(id):
            return "/\(id)/primary"
        case let .deleteTimetable(id):
            return "/\(id)"
        case .getRecentTimetable:
            return "/recent"
        case let .copyTimetable(id):
            return "/\(id)/copy"
        case let .updateTheme(id, _, _):
            return "/\(id)/theme"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getTimetableList:
            return nil
        case .getTimetable:
            return nil
        case let .createTimetable(title, year, semester):
            return ["title": title, "year": year, "semester": semester]
        case let .updateTimetable(_, title):
            return ["title": title]
        case .setPrimaryTimetable:
            return nil
        case .unsetPrimaryTimetable:
            return nil
        case .deleteTimetable:
            return nil
        case .getRecentTimetable:
            return nil
        case .copyTimetable:
            return nil
        case let .updateTheme(_, theme, themeId):
            return ["theme": theme as Any, "themeId": themeId]
        }
    }
}
