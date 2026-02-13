//
//  LiveDependencies.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation

struct NotificationRepositoryKey: DependencyKey {
    static let liveValue: any NotificationRepository = NotificationAPIRepository()
    static let previewValue: any NotificationRepository = {
        let spy = NotificationRepositorySpy()
        spy.fetchUnreadNotificationCountReturnValue = 3
        spy.fetchNotificationsOffsetLimitMarkAsReadReturnValue = [
            .init(
                id: "1",
                title: "",
                message: "테스트 메시지입니다.",
                createdAt: .now,
                type: .normal,
                userID: nil,
                deeplink: nil
            ),
            .init(
                id: "2",
                title: "",
                message: "수강편람이 업로드되었습니다.",
                createdAt: .now,
                type: .courseBook,
                userID: nil,
                deeplink: nil
            ),
            .init(
                id: "3-1",
                title: "",
                message: "강의가 변경되었습니다.",
                createdAt: .now,
                type: .lectureUpdate,
                userID: nil,
                deeplink: URL(
                    string:
                        "snutt-dev://timetable-lecture?timetableId=66adac5e70971558fad958ff&lectureId=6682b60e92e3ec084f94cfe2"
                )
            ),
            .init(
                id: "3-2",
                title: "",
                message: "관심강좌 강의가 변경되었습니다.",
                createdAt: .now,
                type: .lectureUpdate,
                userID: nil,
                deeplink: URL(string: "snutt-dev://bookmarks?year=2024&semester=1&lectureId=6597a421ae212d3ea4c8e2ca")
            ),
            .init(
                id: "4",
                title: "",
                message: "강의가 폐강되었습니다.",
                createdAt: .now,
                type: .lectureRemove,
                userID: nil,
                deeplink: nil
            ),
            .init(
                id: "5",
                title: "",
                message: "빈자리가 생겼습니다.",
                createdAt: .now,
                type: .lectureVacancy,
                userID: nil,
                deeplink: nil
            ),
            .init(
                id: "6",
                title: "",
                message: "XX님과 친구가 되었습니다.",
                createdAt: .now,
                type: .friend,
                userID: nil,
                deeplink: URL(string: "snutt-dev://friends?openDrawer=true")
            ),
            .init(
                id: "7",
                title: "",
                message: "새로운 기능이 출시되었습니다.",
                createdAt: .now,
                type: .newFeature,
                userID: nil,
                deeplink: nil
            ),
        ]
        return spy
    }()
}

extension DependencyValues {
    var notificationRepository: any NotificationRepository {
        get { self[NotificationRepositoryKey.self] }
        set { self[NotificationRepositoryKey.self] = newValue }
    }
}
