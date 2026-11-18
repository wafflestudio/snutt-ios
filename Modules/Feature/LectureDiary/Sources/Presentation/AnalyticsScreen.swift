#if FEATURE_LECTURE_DIARY
//
//  AnalyticsScreen.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import LectureDiaryInterface

enum AnalyticsScreen: AnalyticsLogEvent {
    case diaryWrite(referrer: DiaryWriteReferrer)
    case diaryHistory

    var eventName: String {
        switch self {
        case .diaryWrite:
            "diary_write"
        case .diaryHistory:
            "diary_history"
        }
    }

    var parameters: [String: String]? {
        switch self {
        case .diaryWrite(let referrer):
            ["referrer": referrer.rawValue]
        case .diaryHistory:
            nil
        }
    }
}
#endif
