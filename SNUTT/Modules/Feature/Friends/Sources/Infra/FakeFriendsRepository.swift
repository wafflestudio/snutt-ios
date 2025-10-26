//
//  FakeFriendsRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

#if DEBUG
    import Foundation
    import ThemesInterface
    import TimetableInterface

    /// In-memory fake repository for SwiftUI previews
    actor FakeFriendsRepository: FriendsRepository {
        private var activeFriends: [Friend]
        private var requestedFriends: [Friend]
        private var requestingFriends: [Friend]

        init() {
            self.activeFriends = Friend.previews
            self.requestedFriends = Friend.previewRequested
            self.requestingFriends = [Friend.previewRequesting]
        }

        func getFriends(state: FriendState) async throws -> [Friend] {
            try await Task.sleep(for: .seconds(1))
            switch state {
            case .active:
                return activeFriends
            case .requested:
                return requestedFriends
            case .requesting:
                return requestingFriends
            }
        }

        func requestFriend(nickname: String) async throws -> [Friend] {
            try await Task.sleep(for: .seconds(1))
            let newFriend = Friend(
                id: UUID().uuidString,
                userId: UUID().uuidString,
                nickname: nickname,
                tag: String(Int.random(in: 1000...9999)),
                displayName: nil,
                createdAt: Date()
            )
            requestingFriends.append(newFriend)
            return requestingFriends
        }

        func acceptFriend(friendID: String) async throws {
            try await Task.sleep(for: .seconds(1))
            if let index = requestedFriends.firstIndex(where: { $0.id == friendID }) {
                let friend = requestedFriends.remove(at: index)
                activeFriends.append(friend)
            }
        }

        func declineFriend(friendID: String) async throws {
            requestedFriends.removeAll { $0.id == friendID }
        }

        func breakFriend(friendID: String) async throws {
            activeFriends.removeAll { $0.id == friendID }
        }

        func updateFriendDisplayName(friendID: String, displayName: String) async throws {
            try await Task.sleep(for: .seconds(1))
            if let index = activeFriends.firstIndex(where: { $0.id == friendID }) {
                let friend = activeFriends[index]
                activeFriends[index] = Friend(
                    id: friend.id,
                    userId: friend.userId,
                    nickname: friend.nickname,
                    tag: friend.tag,
                    displayName: displayName,
                    createdAt: friend.createdAt
                )
            }
        }

        func getFriendCoursebooks(friendID: String) async throws -> [Quarter] {
            [
                Quarter(year: 2025, semester: .first),
                Quarter(year: 2024, semester: .second),
                Quarter(year: 2024, semester: .first),
            ]
        }

        func getFriendPrimaryTable(friendID: String, quarter: Quarter) async throws -> Timetable {
            try await Task.sleep(for: .seconds(1))
            return Timetable(
                id: UUID().uuidString,
                title: "친구 시간표",
                quarter: quarter,
                lectures: [],
                userID: friendID,
                theme: .builtInTheme(.snutt)
            )
        }

        func generateFriendLink() async throws -> FriendRequestLink {
            FriendRequestLink(requestToken: UUID().uuidString)
        }

        func acceptFriendByLink(requestToken: String) async throws -> Friend {
            let newFriend = Friend(
                id: UUID().uuidString,
                userId: UUID().uuidString,
                nickname: "카카오친구",
                tag: String(Int.random(in: 1000...9999)),
                displayName: nil,
                createdAt: Date()
            )
            activeFriends.append(newFriend)
            return newFriend
        }
    }
#endif
