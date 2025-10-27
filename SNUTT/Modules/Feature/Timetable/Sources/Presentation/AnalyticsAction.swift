//
//  AnalyticsAction.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import FoundationUtility

enum AnalyticsAction: AnalyticsLogEvent {
    case searchLecture(SearchLectureParameter)
    case addToBookmark(AddToBookmarkParameter)
    case addToTimetable(AddToTimetableParameter)
    case addToVacancy(AddToVacancyParameter)

    var eventName: String {
        switch self {
        case .searchLecture:
            "search_lecture"
        case .addToBookmark:
            "add_to_bookmark"
        case .addToTimetable:
            "add_to_timetable"
        case .addToVacancy:
            "add_to_vacancy"
        }
    }

    var parameters: [String: String]? {
        switch self {
        case let .searchLecture(parameter):
            parameter.stringDictionary
        case let .addToBookmark(parameter):
            parameter.stringDictionary
        case let .addToTimetable(parameter):
            parameter.stringDictionary
        case let .addToVacancy(parameter):
            parameter.stringDictionary
        }
    }
}

public struct AddToBookmarkParameter: Encodable, Sendable {
    typealias Referrer = LectureActionReferrer
    /// 강좌의 레퍼런스 ID
    let lectureID: String
    let referrer: Referrer
}

public struct AddToTimetableParameter: Encodable, Sendable {
    typealias Referrer = LectureActionReferrer
    /// 강좌의 레퍼런스 ID
    let lectureID: String
    let timetableID: String?
    let referrer: Referrer
}

public struct AddToVacancyParameter: Encodable, Sendable {
    typealias Referrer = LectureActionReferrer
    /// 강좌의 레퍼런스 ID
    let lectureID: String
    let referrer: Referrer
}

enum LectureActionReferrer: Encodable, Sendable {
    case search(query: String)
    case lectureDetail
    case bookmark
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .search(query):
            try container.encode("search=\(query)")
        case .lectureDetail:
            try container.encode("lectureDetail")
        case .bookmark:
            try container.encode("bookmark")
        }
    }
}

public struct SearchLectureParameter: Encodable, Sendable {
    let query: String

    /// 예: "2022년 겨울학기"
    let quarter: String
}
