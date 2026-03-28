//
//  NotificationMessage.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import DependenciesUtility
import Foundation

// MARK: - Typed Messages

/// 카카오톡 친구 추가 요청 메시지
///
/// 카카오톡 메시지를 통해 친구 추가 링크를 받은 사용자가 링크를 클릭하여 앱에 진입했을 때 발생하는 메시지입니다.
///
/// ## 플로우
/// 1. **친구 초대**: 사용자 A가 카카오톡으로 친구 초대 메시지 전송 (requestToken 포함)
/// 2. **딥링크 진입**: 사용자 B가 메시지의 "수락하기" 버튼 클릭 → 앱 실행 → URL 파싱 → 이 메시지 발송
/// 3. **메시지 처리**: FriendsViewModel이 메시지 수신 → API 호출하여 친구 수락 → 친구 목록 갱신 및 자동 선택
///
/// - Important: requestToken은 일회성이므로 중복 사용 시 API 에러가 발생합니다.
public struct KakaoFriendRequestMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("kakaoFriendRequest")

    /// 친구 요청 토큰 (일회성)
    public let requestToken: String

    public init(requestToken: String) {
        self.requestToken = requestToken
    }
}

/// 친구 메뉴 열기 메시지
///
/// URL scheme을 통해 친구 화면을 열라는 요청이 들어왔을 때 발생하는 메시지입니다.
public struct OpenFriendsMenuMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("openFriendsMenu")

    public init() {}
}
