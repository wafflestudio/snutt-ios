//
//  AppReviewPromptUseCaseTests.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import Clocks
import Dependencies
import DependenciesAdditions
import Foundation
import Testing

@testable import AppReviewPrompt

@Suite struct AppReviewPromptUseCaseTests {
    @Test func requestReviewIfNeededDoesNothingWhenIneligible() async {
        let now = Date(timeIntervalSince1970: 1_739_616_000)  // 2025-01-01 00:00:00 UTC
        let initialState = AppReviewPromptState(
            installDate: Calendar.current.date(byAdding: .day, value: -1, to: now),
            launchCount: 2,
            lastPromptDate: nil,
            lastPromptVersion: nil
        )

        await withTestDependencies(now: now, version: "1.0.0", initialState: initialState) {
            useCase,
            requester,
            _,
            logger in
            await useCase.requestReviewIfNeeded()
            #expect(requester.requestCount == 0)
            #expect(logger.events.isEmpty)
        }
    }

    @Test func requestReviewIfNeededRequestsAndUpdatesState() async {
        let now = Date(timeIntervalSince1970: 1_739_616_000)
        let installDate = Calendar.current.date(byAdding: .day, value: -3, to: now)
        let initialState = AppReviewPromptState(
            installDate: installDate,
            launchCount: 5,
            lastPromptDate: nil,
            lastPromptVersion: nil
        )

        await withTestDependencies(now: now, version: "1.0.0", initialState: initialState) {
            useCase,
            requester,
            _,
            logger in
            await useCase.requestReviewIfNeeded()
            #expect(requester.requestCount == 1)
            #expect(logger.events.contains("app_review_prompt_requested"))
            let state = currentState()
            #expect(state.lastPromptVersion == "1.0.0")
            #expect(state.lastPromptDate == now)
        }
    }

    @Test func cooldownPreventsRequest() async {
        let now = Date(timeIntervalSince1970: 1_739_616_000)
        let initialState = AppReviewPromptState(
            installDate: Calendar.current.date(byAdding: .day, value: -10, to: now),
            launchCount: 10,
            lastPromptDate: Calendar.current.date(byAdding: .day, value: -10, to: now),
            lastPromptVersion: nil
        )

        await withTestDependencies(now: now, version: "1.0.0", initialState: initialState) {
            useCase,
            requester,
            _,
            logger in
            await useCase.requestReviewIfNeeded()
            #expect(requester.requestCount == 0)
            #expect(logger.events.isEmpty)
        }
    }

    @Test func sameVersionPreventsRequest() async {
        let now = Date(timeIntervalSince1970: 1_739_616_000)
        let initialState = AppReviewPromptState(
            installDate: Calendar.current.date(byAdding: .day, value: -10, to: now),
            launchCount: 10,
            lastPromptDate: nil,
            lastPromptVersion: "1.0.0"
        )

        await withTestDependencies(now: now, version: "1.0.0", initialState: initialState) {
            useCase,
            requester,
            _,
            logger in
            await useCase.requestReviewIfNeeded()
            #expect(requester.requestCount == 0)
            #expect(logger.events.isEmpty)
        }
    }

    @Test func openAppStoreReviewLogsAndOpens() async {
        let now = Date(timeIntervalSince1970: 1_739_616_000)
        let initialState = AppReviewPromptState(
            installDate: Calendar.current.date(byAdding: .day, value: -5, to: now),
            launchCount: 6,
            lastPromptDate: nil,
            lastPromptVersion: nil
        )

        await withTestDependencies(now: now, version: "2.0.0", initialState: initialState) {
            useCase,
            _,
            storeHandler,
            logger in
            await useCase.openAppStoreReview()
            #expect(storeHandler.openCount == 1)
            #expect(logger.events.contains("app_review_store_link_opened"))
        }
    }
}

private func withTestDependencies(
    now: Date,
    version: String,
    initialState: AppReviewPromptState,
    operation: (AppReviewPromptUseCase, TestReviewRequester, TestStoreURLHandler, TestAnalyticsLogger) async -> Void
) async {
    let suiteName = "AppReviewPromptTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defaults.removePersistentDomain(forName: suiteName)

    let requester = TestReviewRequester()
    let storeHandler = TestStoreURLHandler()
    let logger = TestAnalyticsLogger()

    await withDependencies {
        $0.userDefaults = .init(suitename: suiteName) ?? .standard
        $0.date = .init { now }
        $0.bundleInfo = .init(
            bundleIdentifier: "com.wafflestudio.snutt",
            name: "SNUTT",
            displayName: "SNUTT",
            spokenName: "SNUTT",
            shortVersion: version,
            version: "1"
        )
        $0.appReviewPromptRepository = AppReviewPromptUserDefaultsRepository()
        $0.appReviewRequester = requester
        $0.appReviewStoreURLHandler = storeHandler
        $0.analyticsLogger = logger
        $0.continuousClock = ImmediateClock()
    } operation: {
        Dependency(\.userDefaults).wrappedValue[\.appReviewPromptState] = initialState
        let useCase = AppReviewPromptUseCase()
        await operation(useCase, requester, storeHandler, logger)
    }

    defaults.removePersistentDomain(forName: suiteName)
}

private func currentState() -> AppReviewPromptState {
    Dependency(\.userDefaults).wrappedValue[\.appReviewPromptState]
}

private final class TestReviewRequester: AppReviewRequester, @unchecked Sendable {
    private(set) var requestCount: Int = 0

    func requestReview() {
        requestCount += 1
    }
}

private final class TestStoreURLHandler: AppReviewStoreURLHandler, @unchecked Sendable {
    private(set) var openCount: Int = 0

    func openReviewPage() {
        openCount += 1
    }
}

private final class TestAnalyticsLogger: AnalyticsLogger, @unchecked Sendable {
    private(set) var events: [String] = []

    func logEvent(_ event: any AnalyticsLogEvent) {
        events.append(event.eventName)
    }

    func logScreen(_: any AnalyticsLogEvent) {}
}
