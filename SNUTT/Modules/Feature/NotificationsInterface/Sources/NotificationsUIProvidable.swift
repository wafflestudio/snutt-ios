//
//  NotificationsUIProvidable.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

@MainActor
public protocol NotificationsUIProvidable {
    associatedtype NotificationsScene: View
    func makeNotificationsScene() -> NotificationsScene
}

private struct EmptyNotificationsUIProvider: NotificationsUIProvidable {
    func makeNotificationsScene() -> Text {
        Text("NotificationsUIProvider not found.")
    }
}

extension EnvironmentValues {
    @Entry public var notificationsUIProvider: any NotificationsUIProvidable = EmptyNotificationsUIProvider()
}
