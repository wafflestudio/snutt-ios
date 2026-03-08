//
//  AnalyticsScreen.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface

enum AnalyticsScreen: AnalyticsLogEvent {
    case notificationList

    var eventName: String {
        switch self {
        case .notificationList:
            "notification_list"
        }
    }

    var parameters: [String: String]? { nil }
}
