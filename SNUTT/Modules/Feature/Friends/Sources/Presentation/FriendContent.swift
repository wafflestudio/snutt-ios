//
//  FriendContent.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import FriendsInterface
import TimetableInterface

public struct FriendContent: Sendable {
    public let friend: Friend
    public let quarters: [Quarter]
    public var selectedQuarter: Quarter
    public var timetableLoadState: TimetableLoadState

    public enum TimetableLoadState: Sendable {
        case loading
        case loaded(Timetable)

        var timetable: Timetable? {
            switch self {
            case .loading: nil
            case .loaded(let timetable): timetable
            }
        }
    }
}

public enum FriendContentLoadState: Sendable {
    case loading
    case loaded(FriendContent)
    case empty
    case failed
}

public enum FriendsLoadState: Sendable, Equatable {
    case loading
    case loaded([Friend])
    case failed
}
