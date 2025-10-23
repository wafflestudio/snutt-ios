//
//  AnalyticsSDK.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable

@Spyable
public protocol AnalyticsSDK: Sendable {
    func logEvent(_ eventName: String, parameters: [String: Any]?)
}

public enum AnalyticsSDKKey: TestDependencyKey {
    public static let testValue: any AnalyticsSDK = AnalyticsSDKSpy()
}

extension DependencyValues {
    public var analyticsSDK: any AnalyticsSDK {
        get { self[AnalyticsSDKKey.self] }
        set { self[AnalyticsSDKKey.self] = newValue }
    }
}
