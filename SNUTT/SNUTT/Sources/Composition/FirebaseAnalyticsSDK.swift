//
//  FirebaseAnalyticsSDK.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import FirebaseAnalytics
import os

struct FirebaseAnalyticsSDK: AnalyticsSDK {
    private let localLogger = Logger(subsystem: "com.wafflestudio.snutt", category: "Analytics")
    func logEvent(_ eventName: String, parameters: [String: Any]?) {
        FirebaseAnalytics.Analytics.logEvent(eventName, parameters: parameters)
        localLogger.info(
            """
            eventName: "\(eventName)" parameters: \(parameters ?? [:])
            """
        )
    }
}
