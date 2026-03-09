//
//  FriendsViewModel+KakaoRequest.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation

extension FriendsViewModel {
    /// Handle incoming KakaoTalk friend request
    func handleKakaoFriendRequest(requestToken: String) async throws {
        // 1. 친구 사이드바 표시
        isMenuPresented = true

        // 2. API 호출하여 친구 수락
        let newFriend = try await friendsRepository.acceptFriendByLink(requestToken: requestToken)

        // 3. 친구 목록 새로고침
        try await loadActiveFriends()

        // 4. 새로 추가된 친구 자동 선택
        try await selectFriend(newFriend)

        await appReviewService.requestReviewIfNeeded()
    }
}
