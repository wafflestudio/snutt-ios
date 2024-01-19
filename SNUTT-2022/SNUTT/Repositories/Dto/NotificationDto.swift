//
//  NotificationDto.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/02.
//

import Foundation

struct NotificationDto: Decodable {
    var title: String
    let message: String
    let created_at: String
    let type: Int
    let user_id: String?
    var detail: Any?

    enum CodingKeys: String, CodingKey {
        case title
        case message
        case created_at
        case type
        case user_id
        case detail
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        message = try container.decode(String.self, forKey: .message)
        created_at = try container.decode(String.self, forKey: .created_at)
        self.type = try container.decode(Int.self, forKey: .type)
        user_id = try? container.decode(String.self, forKey: .user_id)
        detail = nil

        guard let type = NotificationType(rawValue: type) else { return }
        switch type {
        case .normal,
             .courseBook:
            detail = nil
        case .lectureUpdate,
             .lectureRemove:
            detail = try? container.decode(Detail.self, forKey: .detail)
        case .lectureVacancy, .friend, .newFeature:
            detail = try? container.decode(String.self, forKey: .detail)
        }

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
    }

    struct Lecture: Codable, Hashable {
        let course_title: String
        let lecture_number: String
        let course_number: String
    }

    struct Detail: Codable, Hashable {
        let lecture: Lecture
        let timetable_id: String
    }
}

struct NotificationCountDto: Codable {
    let count: Int
}
