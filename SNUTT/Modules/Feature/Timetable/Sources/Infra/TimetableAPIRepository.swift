//
//  TimetableAPIRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import Foundation
import FoundationUtility
import ThemesInterface
import TimetableInterface

public struct TimetableAPIRepository: TimetableRepository {
    @Dependency(\.apiClient) private var apiClient

    public init() {}

    public func fetchTimetable(timetableID: String) async throws -> Timetable {
        try await apiClient.getTimetable(path: .init(timetableId: timetableID)).ok.body.json.toTimetable()
    }

    public func fetchRecentTimetable() async throws -> Timetable {
        try await apiClient.getMostRecentlyUpdatedTimetables().ok.body.json.toTimetable()
    }

    public func fetchTimetableMetadataList() async throws -> [TimetableMetadata] {
        try await apiClient.getBrief().ok.body.json.map { try $0.toTimetableMetadata() }
    }

    public func updateTimetableTitle(timetableID: String, title: String) async throws -> [TimetableMetadata] {
        try await apiClient.modifyTimetable(path: .init(timetableId: timetableID), body: .json(.init(title: title))).ok
            .body.json.map { try $0.toTimetableMetadata() }
    }

    public func updateTimetableTheme(timetableID: String, theme: Theme) async throws -> Timetable {
        let dto: Components.Schemas.TimetableModifyThemeRequestDto = switch theme.type {
        case let .builtInTheme(theme):
            .init(theme: .init(rawValue: theme.toPayload().rawValue))
        case let .customTheme(themeID):
            .init(theme: nil, themeId: themeID)
        }
        return try await apiClient.modifyTimetableTheme(path: .init(timetableId: timetableID), body: .json(dto)).ok
            .body.json.toTimetable()
    }

    public func setPrimaryTimetable(timetableID: String) async throws {
        _ = try await apiClient.setPrimary(path: .init(timetableId: timetableID)).ok
    }

    public func unsetPrimaryTimetable(timetableID: String) async throws {
        _ = try await apiClient.unSetPrimary(path: .init(timetableId: timetableID)).ok
    }

    public func copyTimetable(timetableID: String) async throws -> [TimetableMetadata] {
        try await apiClient.copyTimetable(.init(path: .init(timetableId: timetableID))).ok.body.json.map {
            try $0.toTimetableMetadata()
        }
    }

    public func deleteTimetable(timetableID: String) async throws -> [TimetableMetadata] {
        try await apiClient.deleteTimetable(.init(path: .init(timetableId: timetableID))).ok.body.json.map {
            try $0.toTimetableMetadata()
        }
    }

    public func addLecture(timetableID: String, lectureID: String) async throws -> Timetable {
        try await apiClient.addLecture(path: .init(timetableId: timetableID, lectureId: lectureID)).ok.body.json
            .toTimetable()
    }

    public func removeLecture(timetableID: String, lectureID: String) async throws -> Timetable {
        try await apiClient.deleteTimetableLecture(.init(path: .init(
            timetableId: timetableID,
            timetableLectureId: lectureID
        ))).ok.body.json.toTimetable()
    }
}

extension Components.Schemas.TimetableLegacyDto {
    func toTimetable() throws -> Timetable {
        let builtInTheme: Theme = switch theme {
        case ._0: .snutt
        case ._1: .fall
        case ._2: .modern
        case ._3: .cherryBlossom
        case ._4: .ice
        case ._5: .lawn
        }
        let themeType: ThemeType = if let themeId {
            .customTheme(themeID: themeId)
        } else {
            .builtInTheme(builtInTheme)
        }
        return try Timetable(
            id: require(_id),
            title: title,
            quarter: Quarter(year: year.asInt(), semester: require(Semester(rawValue: semester.rawValue))),
            lectures: lecture_list.map { try $0.toLecture() },
            userID: user_id,
            theme: themeType
        )
    }
}

extension Theme {
    func toPayload() -> Components.Schemas.TimetableLegacyDto.themePayload {
        switch self {
        case .snutt:
            ._0
        case .fall:
            ._1
        case .modern:
            ._2
        case .cherryBlossom:
            ._3
        case .ice:
            ._4
        case .lawn:
            ._5
        default:
            ._0
        }
    }
}

extension Components.Schemas.TimetableBriefDto {
    fileprivate func toTimetableMetadata() throws -> TimetableMetadata {
        let semester = try require(Semester(rawValue: semester.asInt()))
        let quarter = Quarter(year: year.asInt(), semester: semester)
        return TimetableMetadata(
            id: _id,
            title: title,
            quarter: quarter,
            totalCredit: Int(total_credit),
            isPrimary: isPrimary
        )
    }
}

extension Components.Schemas.TimetableLectureLegacyDto {
    fileprivate func toLecture() throws -> Lecture {
        let isCustom = course_number == nil || course_number == ""
        let timePlaces = try class_time_json.enumerated().compactMap { index, json in
            try json.toTimePlace(index: index, isCustom: isCustom)
        }
        let evLecture: EvLecture? = if let snuttEvLecture {
            .init(evLectureID: snuttEvLecture.evLectureId.asInt(), avgRating: nil, evaluationCount: nil)
        } else {
            nil
        }
        let customColor: LectureColor? = if colorIndex == 0,
                                            let fg = color?.fg,
                                            let bg = color?.bg
        {
            .init(fgHex: fg, bgHex: bg)
        } else {
            nil
        }
        return Lecture(
            id: _id ?? UUID().uuidString,
            lectureID: lecture_id,
            courseTitle: course_title,
            timePlaces: timePlaces,
            lectureNumber: lecture_number,
            instructor: instructor,
            credit: credit,
            courseNumber: course_number,
            department: department,
            academicYear: academic_year,
            remark: remark,
            evLecture: evLecture,
            colorIndex: Int(colorIndex),
            customColor: customColor,
            classification: classification,
            category: category,
            wasFull: false,
            registrationCount: 0,
            quota: quota,
            freshmenQuota: freshman_quota
        )
    }
}

extension Components.Schemas.ClassPlaceAndTimeLegacyDto {
    func toTimePlace(index: Int, isCustom: Bool) throws -> TimePlace {
        let weekday = try require(Weekday(rawValue: day.rawValue))
        let start = startMinute.asInt().quotientAndRemainder(dividingBy: 60)
        let end = endMinute.asInt().quotientAndRemainder(dividingBy: 60)
        return .init(
            id: "\(index)-\(start)-\(end)-\(place ?? "")-\(isCustom)", // FIXME:
            day: weekday,
            startTime: .init(hour: start.quotient, minute: start.remainder),
            endTime: .init(hour: end.quotient, minute: end.remainder),
            place: place ?? "",
            isCustom: isCustom
        )
    }
}

extension Int64 {
    func asInt() -> Int {
        Int(self)
    }
}

extension Int32 {
    fileprivate func asInt() -> Int {
        Int(self)
    }
}
