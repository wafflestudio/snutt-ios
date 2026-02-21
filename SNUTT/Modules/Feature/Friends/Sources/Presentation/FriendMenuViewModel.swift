//
//  FriendMenuViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AppReviewPromptInterface
import Dependencies
import Foundation
import Observation

@Observable
@MainActor
public class FriendMenuViewModel {
    private(set) var friendsViewModel: FriendsViewModel
    var selectedTab: Tab = .active

    @ObservationIgnored
    @Dependency(\.friendsRepository) private var friendsRepository

    @ObservationIgnored
    @Dependency(\.friendsLocalRepository) private var friendsLocalRepository
    @ObservationIgnored
    @Dependency(\.appReviewService) private var appReviewService

    public init(friendsViewModel: FriendsViewModel) {
        self.friendsViewModel = friendsViewModel
    }

    var activeFriendsLoadState: FriendsLoadState {
        friendsViewModel.activeFriendsLoadState
    }

    var requestedFriendsLoadState: FriendsLoadState {
        friendsViewModel.requestedFriendsLoadState
    }

    func selectFriend(_ friend: Friend) async throws {
        try await friendsViewModel.selectFriend(friend)
    }

    func deleteFriend(_ friend: Friend) async throws {
        try await friendsRepository.breakFriend(friendID: friend.id)

        // Clear selected friend if it's the one being deleted
        if friendsViewModel.selectedFriend?.id == friend.id {
            friendsViewModel.selectedFriendContent = .loading
            friendsLocalRepository.storeSelectedFriendID(nil)
        }

        // Reload friends list
        try await friendsViewModel.loadActiveFriends()
    }

    func updateFriendDisplayName(_ friend: Friend, displayName: String) async throws {
        try await friendsRepository.updateFriendDisplayName(friendID: friend.id, displayName: displayName)

        // Reload friends list to reflect the updated display name
        try await friendsViewModel.loadActiveFriends()
    }

    func acceptFriend(_ friend: Friend) async throws {
        try await friendsRepository.acceptFriend(friendID: friend.id)
        await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.friendsViewModel.loadActiveFriends()
            }
            group.addTask {
                try await self.friendsViewModel.refreshRequestedFriends()
            }
        }
        await appReviewService.requestReviewIfNeeded()
    }

    func declineFriend(_ friend: Friend) async throws {
        try await friendsRepository.declineFriend(friendID: friend.id)
        try await friendsViewModel.refreshRequestedFriends()
    }

    enum Tab {
        case active
        case requested
    }
}
