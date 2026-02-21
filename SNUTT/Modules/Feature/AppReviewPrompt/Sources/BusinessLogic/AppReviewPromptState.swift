//
//  AppReviewPromptState.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation

struct AppReviewPromptState: Codable, Sendable, Equatable {
    /// 최초 실행 시점. 설치 후 최소 경과 일수 계산에 사용.
    var installDate: Date?
    /// 앱 실행 횟수. 최소 실행 횟수 조건에 사용.
    var launchCount: Int
    /// 마지막 평점 요청 시점. 쿨다운 계산에 사용.
    var lastPromptDate: Date?
    /// 마지막 요청 당시 앱 버전. 동일 버전 1회 제한에 사용.
    var lastPromptVersion: String?

    static let initial = AppReviewPromptState(
        installDate: nil,
        launchCount: 0,
        lastPromptDate: nil,
        lastPromptVersion: nil
    )
}
