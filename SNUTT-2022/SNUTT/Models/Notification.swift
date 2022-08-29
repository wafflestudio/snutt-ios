//
//  Notification.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/02.
//

import Foundation

struct Notification: Hashable {
    let message: String
    let created_at: String
    let type: NotificationType
    let user_id: String?
    var detail: NotificationDto.Detail?
    var link: String?

    var dateString: String {
        let date = DateFormatter.parse(string: created_at)
        return DateFormatter.parse(date: date)
    }

    var title: String {
        switch type {
        case .normal:
            return "공지"
        case .courseBook:
            return "수강편람"
        case .lectureUpdate:
            return "업데이트 알림"
        case .lectureRemove:
            return "폐강 알림"
        case .link:
            return "공지"
        }
    }

    var imageName: String {
        switch type {
        case .normal:
            return "exclamation"
        case .courseBook:
            return "calendar"
        case .lectureUpdate:
            return "refresh"
        case .lectureRemove:
            return "trash"
        case .link:
            return "megaphone"
        }
    }
}

extension Notification {
    init(from dto: NotificationDto
    ) {
        message = dto.message
        created_at = dto.created_at
        type = NotificationType(rawValue: dto.type) ?? .normal
        user_id = dto.user_id
        detail = nil
        link = nil

        switch type {
        case .normal, .courseBook:
            detail = nil
        case .lectureRemove, .lectureUpdate:
            detail = dto.detail as? NotificationDto.Detail
        case .link:
            link = dto.detail as? String
        }
    }
}

enum NotificationType: Int {
    case normal = 0, courseBook, lectureUpdate, lectureRemove, link
}
