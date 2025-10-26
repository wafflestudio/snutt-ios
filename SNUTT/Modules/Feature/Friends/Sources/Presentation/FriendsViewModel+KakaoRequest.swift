//
//  FriendsViewModel+KakaoRequest.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation

extension FriendsViewModel {
    /// Async stream of KakaoTalk friend request notifications
    func kakaoFriendRequestNotifications() -> AsyncStream<String> {
        NotificationCenter.default.notifications(named: .kakaoFriendRequest)
            .compactMap { notification in
                notification.userInfo?["requestToken"] as? String
            }
            .eraseToStream()
    }

    /// Handle incoming KakaoTalk friend request
    func handleKakaoFriendRequest(requestToken: String) async throws {
        // 1. API 호출하여 친구 수락
        let newFriend = try await friendsRepository.acceptFriendByLink(requestToken: requestToken)

        // 2. 친구 목록 새로고침
        try await loadActiveFriends()

        // 3. 새로 추가된 친구 자동 선택
        try await selectFriend(newFriend)

        // 4. 친구 사이드바 표시
        isMenuPresented = true
    }
}

extension Notification.Name {
    /// 카카오톡 친구 추가 요청 알림
    ///
    /// 카카오톡 메시지를 통해 친구 추가 링크를 받은 사용자가 링크를 클릭하여 앱에 진입했을 때 발생하는 알림입니다.
    ///
    /// ## 플로우
    /// 1. **친구 초대**: 사용자 A가 카카오톡으로 친구 초대 메시지 전송 (requestToken 포함)
    /// 2. **딥링크 진입**: 사용자 B가 메시지의 "수락하기" 버튼 클릭 → 앱 실행 → URL 파싱 → 이 알림 발송
    /// 3. **알림 처리**: FriendsScene이 알림 수신 → API 호출하여 친구 수락 → 친구 목록 갱신 및 자동 선택
    ///
    /// ## UserInfo
    /// - `requestToken` (String): 친구 요청 토큰
    ///
    /// - Important: requestToken은 일회성이므로 중복 사용 시 API 에러가 발생합니다.
    public static let kakaoFriendRequest = Notification.Name("kakaoFriendRequest")
}
