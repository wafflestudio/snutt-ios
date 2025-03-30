//
//  NotificationUIProvider.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import NotificationsInterface

public struct NotificationsUIProvider: NotificationsUIProvidable {
    public typealias NotificationsScene = NotificationsListScene
    public init() {}
    public func makeNotificationsScene() -> NotificationsListScene {
        NotificationsScene()
    }
}
