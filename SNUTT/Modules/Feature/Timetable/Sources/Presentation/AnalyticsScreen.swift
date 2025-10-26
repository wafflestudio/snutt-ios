//
//  AnalyticsScreen.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import Foundation

public enum AnalyticsScreen: AnalyticsLogEvent {
    case timetableHome
    case timetableMenu
    case timetableShare

    case lectureCreate
    case lectureDetail(LectureDetailParameter)
    case lectureList
    case lectureSyllabus(LectureSyllabusParameter)

    case searchHome
    case searchEmpty
    case searchList
    case searchFilter

    case bookmark

    case reviewDetail(ReviewDetailParameter)

    public var eventName: String {
        switch self {
        case .timetableHome:
            "timetable_home"
        case .timetableMenu:
            "timetable_menu"
        case .timetableShare:
            "timetable_share"
        case .lectureCreate:
            "lecture_create"
        case .lectureDetail:
            "lecture_detail"
        case .lectureList:
            "lecture_list"
        case .lectureSyllabus:
            "lecture_syllabus"
        case .searchHome:
            "search_home"
        case .searchEmpty:
            "search_empty"
        case .searchList:
            "search_list"
        case .searchFilter:
            "search_filter"
        case .bookmark:
            "bookmark"
        case .reviewDetail:
            "review_detail"
        }
    }

    public var parameters: [String: String]? {
        switch self {
        case let .lectureDetail(parameter):
            parameter.dictionary
        case let .reviewDetail(parameter):
            parameter.dictionary
        case let .lectureSyllabus(parameter):
            parameter.dictionary
        default: nil
        }
    }
}

public struct LectureDetailParameter: Encodable, Sendable {
    public typealias Referrer = DetailScreenReferrer
    let lectureID: String
    let referrer: Referrer

    public init(lectureID: String, referrer: Referrer) {
        self.lectureID = lectureID
        self.referrer = referrer
    }
}

public struct LectureSyllabusParameter: Encodable, Sendable {
    let lectureID: String
}

public struct ReviewDetailParameter: Encodable, Sendable {
    typealias Referrer = DetailScreenReferrer
    let lectureID: String
    let referrer: Referrer
}

public enum DetailScreenReferrer: Encodable, Sendable {
    case search(query: String)
    case notification
    case bookmark
    case timetable
    case lectureList
    case lectureDetail

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .search(query):
            try container.encode("search=\(query)")
        case .notification:
            try container.encode("notification")
        case .bookmark:
            try container.encode("bookmark")
        case .timetable:
            try container.encode("timetable")
        case .lectureList:
            try container.encode("lectureList")
        case .lectureDetail:
            try container.encode("lectureDetail")
        }
    }
}

extension Encodable {
    fileprivate var dictionary: [String: String] {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed))
            .flatMap { $0 as? [String: String] } ?? [:]
    }
}
