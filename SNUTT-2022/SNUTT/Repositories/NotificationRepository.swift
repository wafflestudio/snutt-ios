//
//  NotificationRepository.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/02.
//

import Alamofire

protocol NotificationRepositoryProtocol {
    func fetchNotifications(limit: Int, offset: Int, explicit: Bool) async throws -> [NotificationDto]
    func fetchNotificationCount() async throws -> NotificationCountDto
}

class NotificationRepository: NotificationRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func fetchNotifications(limit: Int, offset: Int, explicit: Bool) async throws -> [NotificationDto] {
        return try await session
            .request(NotificationRouter.notificationList(limit: limit, offset: offset, explicit: explicit))
            .serializingDecodable([NotificationDto].self)
            .handlingError()
    }

    func fetchNotificationCount() async throws -> NotificationCountDto {
        return try await session
            .request(NotificationRouter.notificationCount)
            .serializingDecodable(NotificationCountDto.self)
            .handlingError()
    }
}
