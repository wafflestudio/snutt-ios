//
//  NotificationAPIRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import APIClientInterface
import Foundation

struct NotificationAPIRepository: NotificationRepository {
    @Dependency(\.apiClient) private var apiClient

    func fetchNotifications(offset: Int, limit: Int, markAsRead: Bool) async throws -> [NotificationModel] {
        let explicit = markAsRead ? 1 : 0
        return try await apiClient.getNotification(query: .init(offset: String(offset), limit: String(limit), explicit: String(explicit))).ok.body.json.compactMap {
            guard let id = $0._id, let type = NotificationType(rawValue: $0._type.rawValue) else { return nil }
            return NotificationModel(id: id ,title: $0.title, message: $0.message, createdAt: $0.created_at, type: type, userID: $0.user_id, deeplink: $0.deeplink.flatMap { URL(string: $0) })
        }
    }

    func fetchUnreadNotificationCount() async throws -> Int {
        try await Int(apiClient.getUnreadCounts(.init()).ok.body.json.count)
    }
}

