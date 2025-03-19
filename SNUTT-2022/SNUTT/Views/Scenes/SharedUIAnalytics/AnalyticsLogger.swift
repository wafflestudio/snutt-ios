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
    /// 이벤트를 기록합니다. `extraParameters`에 추가 매개변수를 정의한 경우 함께 기록됩니다.
    func logEvent(_ event: AnalyticsEvent) {
        logEvent(event, parameters: event.extraParameters)
    }

    /// 스크린 뷰 이벤트를 기록합니다.
    ///
    /// - Note: 스크린 뷰 이벤트에 추가 매개변수가 있는 경우, `screen_view` 이벤트와 함께 보내면 Firebase 콘솔에서 해당 매개변수를 분석하기 어려운 문제가 있습니다.
    /// 따라서 추가 매개변수는 `logEvent(_:parameters:)` 메서드를 사용하여 중복 기록합니다.
    func logScreen(_ screen: AnalyticsScreen) {
        var parameters = [String: Any]()
        parameters[AnalyticsParameterScreenName] = screen.snakeCase
        parameters[AnalyticsParameterScreenClass] = screen.snakeCase
        Analytics.logEvent(AnalyticsEventScreenView, parameters: parameters)
        analyticsLocalLogger.trace("[Analytics] \"\(AnalyticsEventScreenView)\" recorded with \(parameters).")

        if let extraParameters = screen.extraParameters {
            logEvent(screen, parameters: extraParameters)
        }
    }
}

extension FirebaseAnalyticsLogger {
    /// 주어진 매개변수와 함께 이벤트를 기록합니다.
    private func logEvent(_ event: SnakeCaseConvertible, parameters: [String: Any]?) {
        Analytics.logEvent(event.snakeCase, parameters: parameters)
        analyticsLocalLogger.trace("[Analytics] \"\(event.snakeCase)\" recorded with \(parameters ?? [:]).")
    }
}
