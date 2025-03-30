//
//  VacancyAPIRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import APIClientInterface
import TimetableInterface
import Foundation
import FoundationUtility

public struct VacancyAPIRepository: VacancyRepository {
    @Dependency(\.apiClient) private var apiClient

    public init() {}

    public func fetchVacancyLectures() async throws -> [any Lecture] {
        try await apiClient.getVacancyNotificationLectures().ok.body.json.lectures
    }

    public func addVacancyLecture(lectureID: String) async throws {
        _ = try await apiClient.addVacancyNotification(.init(path: .init(lectureId: lectureID))).ok
    }

    public func deleteVacancyLecture(lectureID: String) async throws {
        _ = try await apiClient.deleteVacancyNotification(path: .init(lectureId: lectureID)).ok
    }
}

extension Components.Schemas.LectureDto: @retroactive Lecture {
    public var freshmenQuota: Int32? {
        freshmanQuota
    }

    public var customColor: TimetableInterface.LectureColor? {
        .temporary
    }

    public var evLecture: EvLecture? {
       nil
    }

    public var academicYear: String? {
        academic_year
    }

    public var courseNumber: String? {
        course_number
    }

    public var id: String {
        guard let _id else {
            assertionFailure("id shouldn't be nil.")
            return UUID().uuidString
        }
        return _id
    }

    public var lectureID: String? {
        nil
    }

    public var courseTitle: String {
        course_title
    }

    public var timePlaces: [TimetableInterface.TimePlace] {
        class_time_json
            .enumerated()
            .compactMap { index, json in
                guard let day = Weekday(rawValue: json.day.rawValue) else { return nil }
                let start = json.startMinute.quotientAndRemainder(dividingBy: 60)
                let end = json.endMinute.quotientAndRemainder(dividingBy: 60)
                return TimePlace(
                    id: "\(index)",
                    day: day,
                    startTime: .init(hour: Int(start.quotient), minute: Int(start.remainder)),
                    endTime: .init(hour: Int(end.quotient), minute: Int(end.remainder)),
                    place: json.place ?? ""
                )
            }
    }

    public var lectureNumber: String? {
        lecture_number
    }
}
