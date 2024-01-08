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
            return
        case .lectureUpdate,
             .lectureRemove:
            detail = try? container.decode(Detail.self, forKey: .detail)
            return
        case .lectureVacancy, .friend, .newFeature:
            detail = try? container.decode(String.self, forKey: .detail)
            return
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
