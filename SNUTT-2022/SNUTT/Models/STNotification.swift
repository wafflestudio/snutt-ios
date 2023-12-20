//
//  STNotification.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/02.
//

import Foundation

struct STNotification: Hashable {
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
        case .lectureVacancy:
            return "빈자리 알림"
        case .friend:
            return "친구"
        case .newFeature:
            return "신규 기능"
        }
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
