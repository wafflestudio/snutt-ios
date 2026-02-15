//
//  FriendRequestViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation
import Observation

@Observable
@MainActor
final class FriendRequestViewModel {
    @ObservationIgnored
    @Dependency(\.friendsRepository) private var friendsRepository

    @ObservationIgnored
    @Dependency(\.kakaoShareService) private var kakaoShareService

    private let friendsViewModel: FriendsViewModel

    init(friendsViewModel: FriendsViewModel) {
        self.friendsViewModel = friendsViewModel
    }

    /// Generate request token for KakaoTalk invitation
    func generateRequestToken() async throws -> String {
        let link = try await friendsRepository.generateFriendLink()
        return link.requestToken
    }

    /// Request friend by nickname#tag format
    func requestFriend(nickname: String) async throws {
        try await friendsRepository.requestFriend(nickname: nickname)
        // Refresh requested friends list after successful request
        try await friendsViewModel.refreshRequestedFriends()
    }

    /// Send KakaoTalk friend request
    func sendKakaoFriendRequest() async throws {
        let requestToken = try await generateRequestToken()
        try await kakaoShareService.shareFriendRequest(requestToken: requestToken)
    }

    /// Validate nickname format: 닉네임#태그 (1~10자 + # + 4자리 숫자)
    func validateNickname(_ nickname: String) -> Bool {
        let components = nickname.split(separator: "#")
        guard components.count == 2 else { return false }

        let name = String(components[0])
        let tag = String(components[1])

        // 닉네임: 1~10자
        guard (1...10).contains(name.count) else { return false }

        // 태그: 정확히 4자리 숫자
        guard tag.count == 4, tag.allSatisfy(\.isNumber) else { return false }

        return true
    }
}
