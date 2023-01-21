//
//  BookmarkRouter.swift
//  SNUTT
//
//  Created by 이채민 on 2023/01/21.
//

import Alamofire
import Foundation

enum BookmarkRouter: Router {
    var baseURL: URL { return URL(string: NetworkConfiguration.serverV1BaseURL + "/bookmarks")! }

    case getBookmark(quarter: Quarter)
    case bookmarkLecture(lectureId: String)
    case undoBookmarkLecture(lectureId: String)

    var method: HTTPMethod {
        switch self {
        case .getBookmark:
            return .get
        case .bookmarkLecture:
            return .post
        case .undoBookmarkLecture:
            return .delete
        }
    }

    var path: String {
        switch self {
        case .getBookmark(_):
            return "/"
        case .bookmarkLecture(_):
            return "/lecture"
        case .undoBookmarkLecture(_):
            return "/lecture"
        }
    }

    var parameters: Parameters? {
        switch self {
        case let .getBookmark(quarter):
            return ["year": quarter.year, "semester": quarter.semester.rawValue]
        case let .bookmarkLecture(lectureId):
            return ["lecture_id": lectureId]
        case let .undoBookmarkLecture(lectureId):
            return ["lecture_id": lectureId]
        }
    }
}
