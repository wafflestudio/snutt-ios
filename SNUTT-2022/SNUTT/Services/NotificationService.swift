//
//  NotificationService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/02.
//

import Foundation
import SwiftUI

@MainActor
protocol NotificationServiceProtocol {
    func fetchInitialNotifications(updateLastRead: Bool) async throws
    func fetchMoreNotifications() async throws
    func fetchUnreadNotificationCount() async throws
}

struct NotificationService: NotificationServiceProtocol {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories

    var notificationState: NotificationState {
        appState.notification
    }

    var notificationRepository: NotificationRepositoryProtocol {
        webRepositories.notificationRepository
    }

    private func _fetchNotifications(updateLastRead: Bool = false) async throws {
        let offset = notificationState.perPage * notificationState.pageNum
        let dtos = try await notificationRepository.fetchNotifications(limit: notificationState.perPage,
                                                                       offset: offset,
                                                                       explicit: updateLastRead)
        let models = dtos.map { STNotification(from: $0) }
        notificationState.notifications = offset == 0 ? models : notificationState.notifications + models
        if updateLastRead {
            // no need to call api again; just update locally
            appState.notification.unreadCount = 0
        }
    }

    func fetchInitialNotifications(updateLastRead: Bool) async throws {
        notificationState.pageNum = 0
        try await _fetchNotifications(updateLastRead: updateLastRead)
    }

    func fetchMoreNotifications() async throws {
        notificationState.pageNum += 1
        try await _fetchNotifications(updateLastRead: true)
    }

    func fetchUnreadNotificationCount() async throws {
        let dto = try await notificationRepository.fetchNotificationCount()
        notificationState.unreadCount = dto.count
    }
}

class FakeNotificationService: NotificationServiceProtocol {
    func fetchInitialNotifications(updateLastRead _: Bool) async throws {}
    func fetchMoreNotifications() async throws {}
    func fetchUnreadNotificationCount() async throws {}
}
