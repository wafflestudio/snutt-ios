//
//  NotificationRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Spyable

@Spyable
protocol NotificationRepository: Sendable {
    func fetchNotifications(offset: Int, limit: Int, markAsRead: Bool) async throws -> [NotificationModel]
    func fetchUnreadNotificationCount() async throws -> Int
}
