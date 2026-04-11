#if FEATURE_LECTURE_DIARY
//
//  AnalyticsScreen.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface

enum AnalyticsScreen: AnalyticsLogEvent {
    case diaryWrite

    var eventName: String {
        switch self {
        case .diaryWrite:
            "diary_write"
        }
    }

    var parameters: [String: String]? { nil }
}
#endif
