//
//  NotificationsViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Observation

@Observable
@MainActor
class NotificationsViewModel {
    @ObservationIgnored
    @Dependency(\.notificationRepository) private var notificationRepository

    private let pageLimit = 20
    private var currentPage = 0
    private var isLoading = false
    private var canFetchMore = true
    private(set) var notifications = [NotificationModel]()

    func fetchInitialNotifications() async throws {
        guard !isLoading else { return }
        isLoading = true
        defer {
            isLoading = false
        }
        let fetchedNotifications = try await notificationRepository.fetchNotifications(
            offset: 0,
            limit: pageLimit,
            markAsRead: true
        )
        notifications = fetchedNotifications
        canFetchMore = fetchedNotifications.count == pageLimit
    }

    func fetchMoreNotifications() async throws {
        guard !isLoading, canFetchMore else { return }
        isLoading = true
        defer {
            isLoading = false
        }
        let fetchedNotifications = try await notificationRepository.fetchNotifications(
            offset: (currentPage + 1) * pageLimit,
            limit: pageLimit,
            markAsRead: true
        )
        notifications.append(contentsOf: fetchedNotifications)
        canFetchMore = fetchedNotifications.count == pageLimit
        currentPage += 1
    }

    func fetchUnreadNotificationCount() async throws -> Int {
        try await notificationRepository.fetchUnreadNotificationCount()
    }
}
