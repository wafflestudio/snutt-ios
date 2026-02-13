//
//  AnalyticsScreen.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface

enum AnalyticsScreen: AnalyticsLogEvent {
    case login
    case onboard

    var eventName: String {
        switch self {
        case .login:
            "login"
        case .onboard:
            "onboard"
        }
    }

    var parameters: [String: String]? { nil }
}
