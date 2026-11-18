#if FEATURE_LECTURE_DIARY
//
//  AnalyticsAction.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import LectureDiaryInterface

enum AnalyticsAction: AnalyticsLogEvent {
    case diaryFirstSectionDone
    case diarySubmitted(DiarySubmittedParameter)
    case diaryWriteExit(DiaryWriteExitParameter)
    case diaryAfterSubmit(DiaryAfterSubmitParameter)

    var eventName: String {
        switch self {
        case .diaryFirstSectionDone:
            "diary_first_section_done"
        case .diarySubmitted:
            "diary_submitted"
        case .diaryWriteExit:
            "diary_write_exit"
        case .diaryAfterSubmit:
            "diary_after_submit"
        }
    }

    var parameters: [String: String]? {
        switch self {
        case .diarySubmitted(let parameter):
            parameter.parameters
        case .diaryWriteExit(let parameter):
            parameter.parameters
        case .diaryAfterSubmit(let parameter):
            parameter.stringDictionary
        case .diaryFirstSectionDone:
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

/// Logged only after the server accepts the submission.
struct DiarySubmittedParameter: Sendable, Equatable {
    /// Server ids of the selected class types. Display names may change, so ids are recorded.
    /// Firebase truncates parameter values at 100 characters, so the count is recorded separately.
    let activityTypeIDs: [String]
    /// The comment body itself is never recorded.
    let hasComment: Bool
    let referrer: DiaryWriteReferrer

    var parameters: [String: String] {
        [
            "activity_types": activityTypeIDs.joined(separator: ","),
            "activity_count": String(activityTypeIDs.count),
            "has_comment": String(hasComment),
            "referrer": referrer.rawValue,
        ]
    }
}

struct DiaryWriteExitParameter: Sendable, Equatable {
    enum Step: String, Sendable {
        /// Left before completing class type selection.
        case activity
        /// Left after reaching the questions.
        case questions
    }

    let step: Step
    let referrer: DiaryWriteReferrer

    var parameters: [String: String] {
        [
            "step": step.rawValue,
            "referrer": referrer.rawValue,
        ]
    }
}
#endif
