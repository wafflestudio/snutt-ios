//
//  FriendsRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Foundation
import Spyable
import SwiftUI
import TimetableInterface

@Spyable
protocol FriendsRepository: Sendable {
    func getFriends(state: FriendState) async throws -> [Friend]
    func requestFriend(nickname: String) async throws
    func acceptFriend(friendID: String) async throws
    func declineFriend(friendID: String) async throws
    func breakFriend(friendID: String) async throws
    func updateFriendDisplayName(friendID: String, displayName: String) async throws
    func getFriendCoursebooks(friendID: String) async throws -> [Quarter]
    func getFriendPrimaryTable(friendID: String, quarter: Quarter) async throws -> Timetable
    func generateFriendLink() async throws -> FriendRequestLink
    func acceptFriendByLink(requestToken: String) async throws -> Friend
}
