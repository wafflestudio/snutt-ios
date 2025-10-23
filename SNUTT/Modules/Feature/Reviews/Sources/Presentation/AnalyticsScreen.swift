//
//  AnalyticsScreen.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface

public enum AnalyticsScreen: AnalyticsLogEvent {
    case reviewHome  // done

    public var eventName: String {
        switch self {
        case .reviewHome:
            "review_home"
        }
    }

    public var parameters: [String: String]? { nil }
}
