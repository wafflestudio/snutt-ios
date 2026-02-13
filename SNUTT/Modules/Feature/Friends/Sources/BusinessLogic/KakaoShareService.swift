//
//  KakaoShareService.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation
import Spyable

@Spyable
protocol KakaoShareService: Sendable {
    func isKakaoTalkSharingAvailable() -> Bool
    func shareFriendRequest(requestToken: String) async throws
}

enum KakaoShareServiceKey: TestDependencyKey {
    static let testValue: any KakaoShareService = KakaoShareServiceSpy()
}

extension DependencyValues {
    var kakaoShareService: any KakaoShareService {
        get { self[KakaoShareServiceKey.self] }
        set { self[KakaoShareServiceKey.self] = newValue }
    }
}
