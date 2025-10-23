//
//  AnalyticsLogger.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable

@Spyable
public protocol AnalyticsLogger: Sendable {
    func logEvent(_ event: any AnalyticsLogEvent)
    func logScreen(_ screen: any AnalyticsLogEvent)
}

public protocol AnalyticsLogEvent: Sendable {
    var eventName: String { get }
    var parameters: [String: String]? { get }
}

public struct SimpleLogEvent: AnalyticsLogEvent {
    public var eventName: String
    public var parameters: [String: String]?
    public init(eventName: String, parameters: [String: String]? = nil) {
        self.eventName = eventName
        self.parameters = parameters
    }
}

public enum AnalyticsLoggerKey: TestDependencyKey {
    public static let testValue: any AnalyticsLogger = AnalyticsLoggerSpy()
}

extension DependencyValues {
    public var analyticsLogger: any AnalyticsLogger {
        get { self[AnalyticsLoggerKey.self] }
        set { self[AnalyticsLoggerKey.self] = newValue }
    }
}
