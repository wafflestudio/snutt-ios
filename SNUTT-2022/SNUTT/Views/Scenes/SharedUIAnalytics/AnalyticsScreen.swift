//
//  AnalyticsScreen.swift
//  SNUTT
//
//  Created by user on 2/28/25.
//

public enum AnalyticsScreen: SnakeCaseConvertible {
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

    case reviewHome
    case reviewDetail(ReviewDetailParameter)

    case friends

    case settingsHome
    case settingsAccount
    case settingsTimetable
    case settingsColorScheme
    case settingsSupport
    case settingsDevelopers

    case themeHome
    case themeBasicDetail
    case themeCustomNew
    case themeCustomEdit
    case themePreview
    case themeDownloaded

    case vacancy
    case popup

    case login
    case onboard
}

public struct LectureDetailParameter: Encodable {
    typealias Referrer = DetailScreenReferrer
    let lectureID: String
    let referrer: Referrer
}

public struct ReviewDetailParameter: Encodable {
    typealias Referrer = DetailScreenReferrer
    let lectureID: String
    let referrer: Referrer
}

public struct LectureSyllabusParameter: Encodable {
    let lectureID: String
}

enum DetailScreenReferrer: Encodable {
    case search(query: String)
    case notification
    case bookmark
    case timetable
    case lectureList
    case lectureDetail

    func encode(to encoder: any Encoder) throws {
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

extension AnalyticsScreen {
    var extraParameters: [String: Any]? {
        switch self {
        case let .lectureDetail(parameter):
            parameter.dictionary
        case let .reviewDetail(parameter):
            parameter.dictionary
        case let .lectureSyllabus(parameter):
            parameter.dictionary
        default:
            nil
        }
    }
}
