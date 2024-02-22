//
//  Timetable.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import SwiftUI

// MARK: Timetable

struct Timetable {
    let id: String
    var title: String
    var lectures: [Lecture]
    var theme: BasicTheme?
    let themeId: String?
    var isPrimary: Bool
    let userId: String
    let year: Int
    let semester: Int
    let updatedAt: String

    /// 강의를 검색하는 동안 추가할 강의를 선택했을 때 임시로 나타나는 강의
    var selectedLecture: Lecture?

    /// 테마를 선택했을 때 임시로 사용할 테마
    var selectedTheme: Theme?

    var totalCredit: Int {
        lectures.reduce(0) { $0 + $1.credit }
    }

    var quarter: Quarter {
        Quarter(year: year, semester: .init(rawValue: semester) ?? .first)
    }
    
    var timeMask: [SearchTimeMaskDto] {
        lectures.flatMap { $0.timePlaces }.map { SearchTimeMaskDto(day: $0.day.rawValue, startMinute: $0.startMinute, endMinute: $0.endMinute) }
    }

    private var aggregatedTimePlaces: [TimePlace] {
        (lectures + [selectedLecture])
            .compactMap { $0 }
            .reduce(into: []) { partialResult, lecture in
                partialResult.append(contentsOf: lecture.timePlaces)
            }
    }

    var earliestStartHour: Int? {
        aggregatedTimePlaces.min(by: { $0.startMinute < $1.startMinute })?.startTime.hour
    }

    var lastEndHour: Int? {
        aggregatedTimePlaces.max(by: { $0.endMinute < $1.endMinute })?.endTime.hour
    }

    var lastWeekDay: Weekday? {
        aggregatedTimePlaces.max(by: { $0.day.rawValue < $1.day.rawValue })?.day
    }

    func withSelectedLecture(_ lecture: Lecture?) -> Self {
        var this = self
        this.selectedLecture = lecture
        return this
    }
}

extension Timetable {
    init(from dto: TimetableDto) {
        id = dto._id
        title = dto.title
        userId = dto.user_id
        year = dto.year
        semester = dto.semester
        updatedAt = dto.updated_at
        isPrimary = dto.isPrimary ?? false
        themeId = dto.themeId
        theme = (themeId != nil) ? nil : BasicTheme(rawValue: dto.theme)

        lectures = dto.lecture_list.enumerated().map { index, lectureDto in
            let lecture = Lecture(from: lectureDto, index: index)
            let lectureWithTheme = lecture.withTheme(theme: dto.theme)
            return lectureWithTheme
        }
    }
}

#if DEBUG
    extension Timetable {
        static var preview: Timetable {
            return .init(
                id: UUID().uuidString,
                title: "나의 시간표",
                lectures: [.preview, .preview, .preview],
                theme: BasicTheme(rawValue: 0),
                themeId: "",
                isPrimary: false,
                userId: "1234",
                year: 2022,
                semester: 1,
                updatedAt: "2022-04-02T16:35:53.652Z"
            )
        }
    }
#endif

// MARK: TimetableMetadata

struct TimetableMetadata: Codable {
    let id: String
    let year: Int
    let semester: Int
    let title: String
    let isPrimary: Bool
    let updatedAt: String
    var totalCredit: Int

    var quarter: Quarter {
        Quarter(year: year, semester: .init(rawValue: semester) ?? .first)
    }
}

extension TimetableMetadata: Equatable {
    static func == (lhs: TimetableMetadata, rhs: TimetableMetadata) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.totalCredit == rhs.totalCredit && lhs.isPrimary == rhs.isPrimary
    }
}

extension TimetableMetadata {
    init(from dto: TimetableMetadataDto) {
        id = dto._id
        year = dto.year
        semester = dto.semester
        title = dto.title
        isPrimary = dto.isPrimary ?? false
        updatedAt = dto.updated_at
        totalCredit = dto.total_credit
    }
}

// MARK: Widget Utils

extension Timetable {
    typealias LectureTime = (lecture: Lecture, timePlace: TimePlace)

    enum FilterOption {
        case startTime
        case endTime
    }

    /// Get the remaining `LectureTimes` on a specific date.
    func getRemainingLectureTimes(on date: Date, by filter: FilterOption) -> [LectureTime] {
        let now = Calendar.current.dateComponents([.hour, .minute], from: date)
        guard let nowHour = now.hour,
              let nowMinute = now.minute
        else {
            return []
        }
        let nowTime = TimeUtils.Time(hour: nowHour, minute: nowMinute)

        let remaining = lectures.flatMap { lecture -> [LectureTime] in
            lecture.timePlaces
                .filter { $0.day == date.weekday }
                .filter { timePlace in
                    let filterByTime = {
                        switch filter {
                        case .startTime: return timePlace.startTime
                        case .endTime: return timePlace.endTime
                        }
                    }()
                    return nowTime.hour < filterByTime.hour ||
                        (nowTime.hour == filterByTime.hour && nowTime.minute < filterByTime.minute)
                }
                .map { timePlace in
                    (lecture: lecture, timePlace: timePlace)
                }
        }
        return remaining.sorted { lectureTime1, lectureTime2 in
            lectureTime1.timePlace.startMinute < lectureTime2.timePlace.startMinute
        }
    }

    /// Get the upcoming `LectureTimes` within the next week.
    func getUpcomingLectureTimes() -> (date: Date, lectureTimes: [LectureTime])? {
        let now = Date()
        for offset in 1 ... 7 {
            guard let nextDate = Calendar.current.date(byAdding: .day, value: offset, to: now) else { continue }
            guard let nextDateAtMidnight = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: nextDate) else { continue }
            let lectureTimes = getRemainingLectureTimes(on: nextDateAtMidnight, by: .endTime)
            if !lectureTimes.isEmpty {
                return (date: nextDateAtMidnight, lectureTimes: lectureTimes)
            }
        }
        return nil
    }
}
