//
//  NavigateToPushNotificationSettingsMessage.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import DependenciesUtility
import Foundation

public struct NavigateToPushNotificationSettingsMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("navigateToPushNotificationSettings")

    public init() {}
}
