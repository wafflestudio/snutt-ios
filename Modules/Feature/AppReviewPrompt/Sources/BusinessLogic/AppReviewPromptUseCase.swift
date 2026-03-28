//
//  AppReviewPromptUseCase.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import AppReviewPromptInterface
import Dependencies
import Foundation

struct AppReviewPromptUseCase: AppReviewService {
    @Dependency(\.appReviewPromptRepository) private var repository
    @Dependency(\.appReviewRequester) private var appReviewRequester
    @Dependency(\.appReviewStoreURLHandler) private var appReviewStoreURLHandler
    @Dependency(\.date) private var date
    @Dependency(\.bundleInfo.shortVersion) private var marketingVersion
    @Dependency(\.analyticsLogger) private var analyticsLogger
    @Dependency(\.continuousClock) private var clock

    private let policy: AppReviewPromptPolicy

    init(policy: AppReviewPromptPolicy = .default) {
        self.policy = policy
    }

    func recordAppLaunch() {
        var state = repository.loadState()
        if state.installDate == nil {
            state.installDate = date()
        }
        state.launchCount = max(0, state.launchCount + 1)
        repository.saveState(state)
    }

    func requestReviewIfNeeded() async {
        let now = date()
        let currentVersion = marketingVersion
        var state = repository.loadState()

        guard policy.isEligible(state: state, now: now, currentVersion: currentVersion) else { return }

        try? await clock.sleep(for: .seconds(1))

        let requestTime = date()
        state = repository.loadState()
        guard policy.isEligible(state: state, now: requestTime, currentVersion: currentVersion) else { return }

        analyticsLogger.logEvent(AppReviewAnalyticsEvent.promptRequested)
        appReviewRequester.requestReview()
        state.lastPromptDate = requestTime
        state.lastPromptVersion = currentVersion
        repository.saveState(state)
    }

    func openAppStoreReview() async {
        analyticsLogger.logEvent(AppReviewAnalyticsEvent.storeLinkOpened)
        appReviewStoreURLHandler.openReviewPage()
    }
}
