//
//  AppReviewService.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable

@Spyable
public protocol AppReviewService: Sendable {
    func recordAppLaunch()
    func requestReviewIfNeeded() async
    func openAppStoreReview() async
}

public enum AppReviewServiceKey: TestDependencyKey {
    public static let testValue: any AppReviewService = AppReviewServiceSpy()
}

extension DependencyValues {
    public var appReviewService: any AppReviewService {
        get { self[AppReviewServiceKey.self] }
        set { self[AppReviewServiceKey.self] = newValue }
    }
}
