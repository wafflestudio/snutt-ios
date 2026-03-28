//
//  NotificationCountRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable

@Spyable
public protocol NotificationCountRepository: Sendable {
    func fetchUnreadNotificationCount() async throws -> Int
}

public enum NotificationCountRepositoryKey: TestDependencyKey {
    public static let testValue: any NotificationCountRepository = {
        let spy = NotificationCountRepositorySpy()
        spy.fetchUnreadNotificationCountReturnValue = 0
        return spy
    }()
}

extension DependencyValues {
    public var notificationCountRepository: any NotificationCountRepository {
        get { self[NotificationCountRepositoryKey.self] }
        set { self[NotificationCountRepositoryKey.self] = newValue }
    }
}
