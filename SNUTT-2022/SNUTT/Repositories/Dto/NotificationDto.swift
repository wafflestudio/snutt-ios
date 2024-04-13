//
//  NotificationDto.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/02.
//

import Foundation

struct NotificationDto: Decodable {
    let title: String
    let message: String
    let created_at: String
    let type: Int
    let user_id: String?
    let deeplink: String?

    enum CodingKeys: String, CodingKey {
        case title
        case message
        case created_at
        case type
        case user_id
        case deeplink
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        created_at = try container.decode(String.self, forKey: .created_at)
        user_id = try? container.decode(String.self, forKey: .user_id)
        type = try container.decode(Int.self, forKey: .type)
        deeplink = try? container.decode(String.self, forKey: .deeplink)

        let type = NotificationType(rawValue: type) ?? .normal
        var title = try container.decode(String.self, forKey: .title)
        if title.isEmpty {
            switch type {
            case .normal:
                title = "공지"
            case .courseBook:
                title = "수강편람"
            case .lectureUpdate:
                title = "업데이트 알림"
            case .lectureRemove:
                title = "폐강 알림"
            case .lectureVacancy:
                title = "빈자리 알림"
            case .friend:
                title = "친구"
            case .newFeature:
                title = "신규 기능"
            }
        }
        self.title = title
    }
}

struct NotificationCountDto: Codable {
    let count: Int
}
