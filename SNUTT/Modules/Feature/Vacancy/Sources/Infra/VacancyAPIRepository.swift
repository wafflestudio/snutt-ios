//
//  VacancyAPIRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import Foundation
import FoundationUtility
import TimetableInterface

public struct VacancyAPIRepository: VacancyRepository {
    @Dependency(\.apiClient) private var apiClient

    public init() {}

    public func fetchVacancyLectures() async throws -> [Lecture] {
        try await apiClient.getVacancyNotificationLectures().ok.body.json.lectures.map { try $0.toLecture() }
    }

    public func addVacancyLecture(lectureID: String) async throws {
        _ = try await apiClient.addVacancyNotification(.init(path: .init(lectureId: lectureID))).ok
    }

    public func deleteVacancyLecture(lectureID: String) async throws {
        _ = try await apiClient.deleteVacancyNotification(path: .init(lectureId: lectureID)).ok
    }
}

extension Components.Schemas.LectureDto {
    fileprivate func toLecture() throws -> Lecture {
        let timePlaces: [TimePlace] = try class_time_json
            .enumerated()
            .compactMap { index, json in
                let day = try require(Weekday(rawValue: json.day.rawValue))
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
        return Lecture(
            id: _id ?? UUID().uuidString,
            lectureID: nil,
            courseTitle: course_title,
            timePlaces: timePlaces,
            lectureNumber: lecture_number,
            instructor: instructor,
            credit: credit,
            courseNumber: course_number,
            department: department,
            academicYear: academic_year,
            remark: remark,
            evLecture: nil,
            colorIndex: 0,
            customColor: .temporary,
            classification: classification,
            category: category,
            wasFull: wasFull,
            registrationCount: registrationCount,
            quota: quota,
            freshmenQuota: freshmanQuota
        )
    }
}
