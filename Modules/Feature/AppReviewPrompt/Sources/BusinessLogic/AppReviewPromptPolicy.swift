//
//  AppReviewPromptPolicy.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation

struct AppReviewPromptPolicy: Sendable {
    /// 설치 후 최소 경과 일수. 이보다 적으면 요청하지 않음.
    let minimumDaysSinceInstall: Int
    /// 최소 앱 실행 횟수. 이보다 적으면 요청하지 않음.
    let minimumLaunchCount: Int
    /// 마지막 요청 이후 재노출까지의 최소 일수.
    let cooldownDays: Int

    static let `default` = AppReviewPromptPolicy(
        minimumDaysSinceInstall: 3,
        minimumLaunchCount: 5,
        cooldownDays: 30
    )

    func isEligible(state: AppReviewPromptState, now: Date, currentVersion: String) -> Bool {
        guard let installDate = state.installDate else { return false }
        guard state.launchCount >= minimumLaunchCount else { return false }

        let calendar = Calendar.current
        let daysSinceInstall = calendar.dateComponents([.day], from: installDate, to: now).day ?? 0
        guard daysSinceInstall >= minimumDaysSinceInstall else { return false }

        if let lastPromptDate = state.lastPromptDate,
            let nextAllowedDate = calendar.date(byAdding: .day, value: cooldownDays, to: lastPromptDate),
            now < nextAllowedDate
        {
            return false
        }

        if let lastPromptVersion = state.lastPromptVersion, lastPromptVersion == currentVersion {
            return false
        }

        return true
    }
}
