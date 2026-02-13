//
//  FirebaseAnalyticsLogger.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import Dependencies
import os

public struct FirebaseAnalyticsLogger: AnalyticsLogger {
    @Dependency(\.analyticsSDK) private var analytics

    public init() {}

    public func logEvent(_ event: any AnalyticsLogEvent) {
        analytics.logEvent(event.eventName, parameters: event.parameters)
    }

    public func logScreen(_ screen: any AnalyticsLogEvent) {
        var parameters = [String: String]()
        parameters[Constants.screenName] = screen.eventName
        parameters[Constants.screenClass] = screen.eventName
        analytics.logEvent(Constants.screenView, parameters: parameters)

        if let extraParameters = screen.parameters {
            analytics.logEvent(screen.eventName, parameters: extraParameters)
        }
    }

    private enum Constants {
        static let screenName = "screen_name"
        static let screenClass = "screen_class"
        static let screenView = "screen_view"
    }
}
