//
//  NavigateToNotificationsMessage.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import DependenciesUtility
import Foundation

public struct NavigateToNotificationsMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("navigateToNotifications")

    public init() {}
}
