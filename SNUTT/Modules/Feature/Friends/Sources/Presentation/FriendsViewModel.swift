//
//  FriendsViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation
import Observation
import TimetableInterface

@Observable
@MainActor
public class FriendsViewModel {
    @ObservationIgnored
    @Dependency(\.friendsRepository) var friendsRepository

    @ObservationIgnored
    @Dependency(\.friendsLocalRepository) private var friendsLocalRepository

    @ObservationIgnored
    @Dependency(\.timetableLocalRepository) private var timetableLocalRepository

    var isMenuPresented = false
    var isRequestSheetPresented = false
    var isGuidePopupPresented = false

    private(set) var activeFriendsLoadState: FriendsLoadState = .loading
    private(set) var requestedFriendsLoadState: FriendsLoadState = .loading
    var selectedFriendContent: FriendContentLoadState = .loading

    public init() {}

    var selectedFriend: Friend? {
        switch selectedFriendContent {
        case .loaded(let friendContent):
            friendContent.friend
        default: nil
        }
    }

    var activeFriends: [Friend] {
        if case let .loaded(friends) = activeFriendsLoadState {
            return friends
        }
        return []
    }

    var requestedFriends: [Friend] {
        if case let .loaded(friends) = requestedFriendsLoadState {
            return friends
        }
        return []
    }

    var timetableConfiguration: TimetableConfiguration {
        timetableLocalRepository.loadTimetableConfiguration()
    }

    func initialLoadFriends() async throws {
        await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.loadActiveFriends()
            }
            group.addTask {
                try await self.loadRequestedFriends()
            }
        }
    }

    func selectFriend(_ friend: Friend) async throws {
        do {
            if selectedFriend?.id != friend.id {
                // Display skeleton only when different friend is selected
                selectedFriendContent = .loading
            }
            friendsLocalRepository.storeSelectedFriendID(friend.id)
            let quarters = try await friendsRepository.getFriendCoursebooks(friendID: friend.id)
            guard let firstQuarter = quarters.first else {
                // No quarters available
                selectedFriendContent = .loaded(
                    .init(friend: friend, quarters: [], selectedQuarter: .fallback, timetableLoadState: .loading)
                )
                return
            }
            let timetable = try? await friendsRepository.getFriendPrimaryTable(
                friendID: friend.id,
                quarter: firstQuarter
            )
            let friendContent = FriendContent(
                friend: friend,
                quarters: quarters,
                selectedQuarter: firstQuarter,
                timetableLoadState: {
                    switch timetable {
                    case .some(let timetable): .loaded(timetable)
                    case .none: .loading
                    }
                }()
            )
            selectedFriendContent = .loaded(friendContent)
        } catch {
            selectedFriendContent = .failed
            throw error
        }
    }

    func selectQuarter(_ quarter: Quarter) async throws {
        guard case var .loaded(friendContent) = selectedFriendContent else { return }
        // Update selected quarter and set timetable to loading
        friendContent.selectedQuarter = quarter
        // Load timetable for the new quarter
        let timetable = try await friendsRepository.getFriendPrimaryTable(
            friendID: friendContent.friend.id,
            quarter: quarter
        )
        friendContent.timetableLoadState = .loaded(timetable)
        selectedFriendContent = .loaded(friendContent)
    }
}

extension FriendsViewModel {
    public func loadActiveFriends() async throws {
        do {
            let friends = try await friendsRepository.getFriends(state: .active)
            activeFriendsLoadState = .loaded(friends)

            let localSelectedFriendID = friendsLocalRepository.loadSelectedFriendID()
            if let localSelectedFriendID, let friend = friends.first(where: { $0.id == localSelectedFriendID }) {
                try await selectFriend(friend)
            } else if let anyFirstFriend = friends.first {
                try await selectFriend(anyFirstFriend)
            } else {
                selectedFriendContent = .empty
            }
        } catch {
            activeFriendsLoadState = .failed
            throw error
        }

    }

    private func loadRequestedFriends() async throws {
        do {
            let friends = try await friendsRepository.getFriends(state: .requested)
            requestedFriendsLoadState = .loaded(friends)
        } catch {
            requestedFriendsLoadState = .failed
            throw error
        }
    }

    /// Refresh requested friends list (used after sending friend request)
    func refreshRequestedFriends() async throws {
        try await loadRequestedFriends()
    }
}

extension Quarter {
    fileprivate static var fallback: Self {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Quarter(year: currentYear, semester: .first)
    }
}
