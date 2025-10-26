//
//  AnalyticsScreen.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface

public enum AnalyticsScreen: AnalyticsLogEvent {
    case friends

    public var eventName: String {
        switch self {
        case .friends:
            "friends"
        }
    }

    public var parameters: [String: String]? { nil }
}
