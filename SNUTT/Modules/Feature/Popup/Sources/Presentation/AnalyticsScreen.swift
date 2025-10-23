//
//  AnalyticsScreen.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface

enum AnalyticsScreen: AnalyticsLogEvent {
    case popup

    var eventName: String {
        switch self {
        case .popup:
            "popup"
        }
    }

    var parameters: [String: String]? { nil }
}
