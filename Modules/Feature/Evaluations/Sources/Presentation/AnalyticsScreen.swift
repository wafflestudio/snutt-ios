//
//  AnalyticsScreen.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface

public enum AnalyticsScreen: AnalyticsLogEvent {
    case reviewHome

    public var eventName: String {
        switch self {
        case .reviewHome:
            "review_home"
        }
    }

    public var parameters: [String: String]? { nil }
}
