//
//  AnalyticsEvent.swift
//  SNUTT
//
//  Created by user on 2/28/25.
//

public enum AnalyticsEvent: SnakeCaseConvertible {
    case login(LoginParameter)
    case logout
    case signUp
    case searchLecture(SearchLectureParameter)
    case addToBookmark(AddToBookmarkParameter)
    case addToTimetable(AddToTimetableParameter)
    case addToVacancy(AddToVacancyParameter)
}

public struct LoginParameter: Encodable {
    enum Provider: String, Encodable {
        case local
        case google
        case apple
        case facebook
        case kakao
    }
    let provider: Provider
}

public struct AddToBookmarkParameter: Encodable {
    typealias Referrer = LectureActionReferrer
    /// 강좌의 레퍼런스 ID
    let lectureID: String
    let referrer: Referrer
}

public struct AddToTimetableParameter: Encodable {
    typealias Referrer = LectureActionReferrer
    /// 강좌의 레퍼런스 ID
    let lectureID: String
    let timetableID: String?
    let referrer: Referrer
}

public struct AddToVacancyParameter: Encodable {
    typealias Referrer = LectureActionReferrer
    /// 강좌의 레퍼런스 ID
    let lectureID: String
    let referrer: Referrer
}

enum LectureActionReferrer: Encodable {
    case search(query: String)
    case lectureDetail
    case bookmark
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .search(let query):
            try container.encode("search=\(query)")
        case .lectureDetail:
            try container.encode("lectureDetail")
        case .bookmark:
            try container.encode("bookmark")
        }
    }
}

public struct SearchLectureParameter: Encodable {
    let query: String

    /// 예: "2022년 겨울학기"
    let quarter: String

    let page: Int
}

extension AnalyticsEvent {
    var extraParameters: [String: Any] {
        switch self {
        case .login(let parameter):
            parameter.dictionary
        case .addToBookmark(let parameter):
            parameter.dictionary
        case .searchLecture(let parameter):
            parameter.dictionary
        case .addToTimetable(let parameter):
            parameter.dictionary
        case .addToVacancy(let parameter):
            parameter.dictionary
        default:
            [:]
        }
    }
}
