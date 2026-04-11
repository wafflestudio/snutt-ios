#if FEATURE_LECTURE_DIARY
//
//  AnalyticsAction.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface

enum AnalyticsAction: AnalyticsLogEvent {
    case diaryFirstSectionDone
    case diarySubmitted
    case diaryAfterSubmit(DiaryAfterSubmitParameter)

    var eventName: String {
        switch self {
        case .diaryFirstSectionDone:
            "diary_first_section_done"
        case .diarySubmitted:
            "diary_submitted"
        case .diaryAfterSubmit:
            "diary_after_submit"
        }
    }

    var parameters: [String: String]? {
        switch self {
        case .diaryAfterSubmit(let parameter):
            parameter.stringDictionary
        case .diaryFirstSectionDone, .diarySubmitted:
            nil
        }
    }
}

struct DiaryAfterSubmitParameter: Encodable, Sendable {
    enum Action: String, Encodable, Sendable {
        case next
        case home
        case review
    }
    let action: Action
}
#endif
