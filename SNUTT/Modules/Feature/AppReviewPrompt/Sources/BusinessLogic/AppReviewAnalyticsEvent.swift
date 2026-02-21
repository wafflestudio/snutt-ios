//
//  AppReviewAnalyticsEvent.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface

enum AppReviewAnalyticsEvent: AnalyticsLogEvent {
    case promptRequested
    case storeLinkOpened

    var eventName: String {
        switch self {
        case .promptRequested:
            "app_review_prompt_requested"
        case .storeLinkOpened:
            "app_review_store_link_opened"
        }
    }

    var parameters: [String: String]? {
        nil
    }
}
