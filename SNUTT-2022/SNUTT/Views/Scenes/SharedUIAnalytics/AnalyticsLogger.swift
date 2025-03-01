//
//  AnalyticsLogger.swift
//  SNUTT
//
//  Created by user on 3/1/25.
//

import FirebaseAnalytics

protocol AnalyticsLogger {
    func logEvent(_ event: AnalyticsEvent)
    func logScreen(_ screen: AnalyticsScreen)
}

struct FirebaseAnalyticsLogger: AnalyticsLogger {
    func logEvent(_ event: AnalyticsEvent) {
        Analytics.logEvent(event.snakeCase, parameters: event.extraParameters)
        analyticsLocalLogger.trace("[AnalyticsEvent] \(event.snakeCase) recorded with \(event.extraParameters).")
    }

    func logScreen(_ screen: AnalyticsScreen) {
        var parameters = screen.extraParameters
        parameters[AnalyticsParameterScreenName] = screen.snakeCase
        parameters[AnalyticsParameterScreenClass] = screen.snakeCase
        Analytics.logEvent(AnalyticsEventScreenView, parameters: screen.extraParameters)
        analyticsLocalLogger.trace("[AnalyticsScreen] \(screen.snakeCase) recorded with \(screen.extraParameters).")
    }
}
