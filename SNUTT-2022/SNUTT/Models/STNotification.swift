//
//  STNotification.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/02.
//

import Foundation

struct STNotification: Hashable {
    let title: String
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

    var imageName: String {
        switch type {
        case .normal:
            return "noti.exclamation"
        case .courseBook:
            return "noti.calendar"
        case .lectureUpdate:
            return "noti.refresh"
        case .lectureRemove:
            return "noti.trash"
        case .lectureVacancy:
            return "noti.vacancy"
        case .friend:
            return "noti.friend"
        case .newFeature:
            return "noti.megaphone"
        }
    }
}

extension STNotification {
    init(from dto: NotificationDto
    ) {
        title = dto.title
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
        case .lectureVacancy, .friend, .newFeature:
            link = dto.detail as? String
        }
    }
}

enum NotificationType: Int {
    case normal = 0, courseBook, lectureUpdate, lectureRemove, lectureVacancy, friend, newFeature
}
