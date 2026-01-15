//
//  Friend.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation

public struct Friend: Sendable, Equatable, Identifiable {
    public let id: String
    public let userId: String
    public let nickname: String
    public let tag: String
    public let displayName: String?

    public var effectiveDisplayName: String {
        displayName ?? "\(nickname)#\(tag)"
    }

    public init(
        id: String,
        userId: String,
        nickname: String,
        tag: String,
        displayName: String? = nil,
    ) {
        self.id = id
        self.userId = userId
        self.nickname = nickname
        self.tag = tag
        self.displayName = displayName
    }
}

/// Friend request link response
public struct FriendRequestLink: Sendable, Equatable {
    public let requestToken: String

    public init(requestToken: String) {
        self.requestToken = requestToken
    }
}

/// Friend state type for filtering
public enum FriendState: String, Sendable {
    /// 친구 관계 완료 상태
    case active = "ACTIVE"
    /// 내가 받은 친구 요청 (상대방이 요청 → 나에게 요청됨)
    case requested = "REQUESTED"
    /// 내가 보낸 친구 요청 (나에서 요청 → 상대방을 요청 중)
    case requesting = "REQUESTING"
}

#if DEBUG
    extension Friend {
        public static let preview1 = Friend(
            id: "friend1",
            userId: "user1",
            nickname: "김철수",
            tag: "1234",
            displayName: "철수",
        )

        public static let preview2 = Friend(
            id: "friend2",
            userId: "user2",
            nickname: "이영희",
            tag: "5678",
            displayName: nil,
        )

        public static let preview3 = Friend(
            id: "friend3",
            userId: "user3",
            nickname: "박민수",
            tag: "9012",
            displayName: "민수님",
        )

        public static let preview4 = Friend(
            id: "friend4",
            userId: "user4",
            nickname: "최지현",
            tag: "3456",
            displayName: nil,
        )

        public static let previewRequested = [
            Friend(
                id: "friend5",
                userId: "user5",
                nickname: "정수빈",
                tag: "7890",
                displayName: nil,
            ),
            Friend(
                id: "friend5b",
                userId: "user5b",
                nickname: "김민수",
                tag: "7891",
                displayName: nil,
            ),
        ]

        public static let previewRequesting = Friend(
            id: "friend6",
            userId: "user6",
            nickname: "강예진",
            tag: "2345",
            displayName: nil,
        )

        public static var previews: [Friend] {
            [preview1, preview2, preview3, preview4]
        }
    }
#endif
