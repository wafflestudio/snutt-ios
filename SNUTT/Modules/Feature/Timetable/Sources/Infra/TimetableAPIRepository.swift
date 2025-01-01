//
//  TimetableAPIRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import Foundation
import TimetableInterface
import FoundationUtility

public struct TimetableAPIRepository: TimetableRepository {
    @Dependency(\.apiClient) private var apiClient

    public init() {}

    public func fetchTimetable(timetableID: String) async throws -> any Timetable {
        try await apiClient.getTimetable(path: .init(timetableId: timetableID)).ok.body.json
    }

    public func fetchRecentTimetable() async throws -> any Timetable {
        try await apiClient.getMostRecentlyUpdatedTimetables().ok.body.json
    }

    public func fetchTimetableMetadataList() async throws -> [any TimetableMetadata] {
        try await apiClient.getBrief().ok.body.json
    }

    public func updateTimetableTitle(timetableID _: String, title _: String) async throws -> [any Timetable] {
        fatalError()
    }

    public func setPrimaryTimetable(timetableID _: String) async throws {
        fatalError()
    }
}

extension Components.Schemas.TimetableLegacyDto: @retroactive Timetable {
    public var id: String {
        guard let _id else {
            assertionFailure("id shouldn't be nil.")
            return UUID().uuidString
        }
        return _id
    }

    public var userID: String { user_id }

    public var quarter: Quarter {
        guard let semester = Semester(rawValue: semester.rawValue)
        else {
            fatalError()
        }
        return .init(
            year: year.asInt(),
            semester: semester
        )
    }

    public var lectures: [any TimetableInterface.Lecture] {
        lecture_list
    }

    public var defaultTheme: Theme? {
        guard themeId == nil else { return nil }
        return switch theme {
        case ._0:
            .snutt
        case ._1:
            .fall
        case ._2:
            .modern
        case ._3:
            .cherryBlossom
        case ._4:
            .ice
        case ._5:
            .lawn
        }
    }
}

extension Components.Schemas.TimetableBriefDto: @retroactive TimetableMetadata {
    public var quarter: TimetableInterface.Quarter {
        guard let semester = Semester(rawValue: Int(semester))
        else {
            fatalError()
        }
        return .init(
            year: year.asInt(),
            semester: semester
        )
    }

    public var totalCredit: Int {
        Int(total_credit)
    }

    public var id: String {
        _id
    }
}

extension Components.Schemas.TimetableLectureLegacyDto: @retroactive Lecture {
    public var freshmenQuota: Int32? {
        freshman_quota
    }
    
    public var customColor: TimetableInterface.LectureColor? {
        if colorIndex == 0,
           let fg = color?.fg,
           let bg = color?.bg
        {
            return .init(fgHex: fg, bgHex: bg)
        }
        return nil
    }
    
    public var evLecture: EvLecture? {
        guard let snuttEvLecture else { return nil }
        return .init(evLectureID: snuttEvLecture.evLectureId.asInt(), avgRating: nil, evaluationCount: nil)
    }

    public var courseNumber: String? {
        course_number
    }

    public var academicYear: String? {
        academic_year
    }

    public var lectureNumber: String? {
        lecture_number
    }

    public var id: String {
        guard let _id else {
            assertionFailure("id shouldn't be nil.")
            return UUID().uuidString
        }
        return _id
    }

    public var lectureID: String? { lecture_id }
    public var courseTitle: String { course_title }
    public var timePlaces: [TimePlace] {
        class_time_json
            .enumerated()
            .compactMap { index, json in
                TimePlace(dto: json, index: index, isCustom: isCustom)
            }
    }
}

extension TimePlace {
    init?(dto: Components.Schemas.ClassPlaceAndTimeLegacyDto, index: Int, isCustom: Bool) {
        guard let weekday = Weekday(rawValue: dto.day.rawValue) else { return nil }
        let start = dto.startMinute.asInt().quotientAndRemainder(dividingBy: 60)
        let end = dto.endMinute.asInt().quotientAndRemainder(dividingBy: 60)
        self.init(
            id: "\(index)-\(start)-\(end)-\(dto.place ?? "")-\(isCustom)", // FIXME:
            day: weekday,
            startTime: .init(hour: start.quotient, minute: start.remainder),
            endTime: .init(hour: end.quotient, minute: end.remainder),
            place: dto.place ?? "",
            isCustom: isCustom
        )
    }
}

extension Int64 {
    func asInt() -> Int {
        Int(self)
    }
}

private extension Int32 {
    func asInt() -> Int {
        Int(self)
    }
}
