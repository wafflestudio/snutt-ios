//
//  NotificationMessage.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import DependenciesUtility
import Foundation

// MARK: - Typed Messages

/// 커스텀 테마 업데이트 메시지
///
/// 커스텀 테마가 생성되거나 수정되었을 때 발생하는 메시지입니다.
/// ThemeViewModel이 이 메시지를 수신하여 테마 목록을 다시 로드합니다.
struct CustomThemeDidUpdateMessage: NotificationCenter.TypedMessage {
    static let name = Notification.Name("customThemeDidUpdate")

    init() {}
}
