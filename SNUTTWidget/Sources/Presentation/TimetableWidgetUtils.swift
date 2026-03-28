//
//  TimetableWidgetUtils.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation
import FoundationUtility
import TimetableInterface
import TimetableUIComponents

extension Timetable {
    typealias LectureTime = (lecture: Lecture, timePlace: TimePlace)

    /// Get the remaining `LectureTimes` on a specific date.
    func getRemainingLectureTimes(on date: Date, by filter: FilterOption) -> [LectureTime] {
        let now = Calendar.current.dateComponents([.hour, .minute], from: date)
        guard let nowHour = now.hour,
            let nowMinute = now.minute
        else {
            return []
        }
        let nowTime = Time(hour: nowHour, minute: nowMinute)

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
                    return nowTime.hour < filterByTime.hour
                        || (nowTime.hour == filterByTime.hour && nowTime.minute < filterByTime.minute)
                }
                .map { timePlace in
                    (lecture: lecture, timePlace: timePlace)
                }
        }
        return remaining.sorted { lectureTime1, lectureTime2 in
            lectureTime1.timePlace.startTime.absoluteMinutes < lectureTime2.timePlace.startTime.absoluteMinutes
        }
    }

    /// Get the upcoming `LectureTimes` within the next week.
    func getUpcomingLectureTimes() -> (date: Date, lectureTimes: [LectureTime])? {
        let now = Date()
        for offset in 1...7 {
            guard let nextDate = Calendar.current.date(byAdding: .day, value: offset, to: now) else { continue }
            guard let nextDateAtMidnight = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: nextDate)
            else { continue }
            let lectureTimes = getRemainingLectureTimes(on: nextDateAtMidnight, by: .endTime)
            if !lectureTimes.isEmpty {
                return (date: nextDateAtMidnight, lectureTimes: lectureTimes)
            }
        }
        return nil
    }
}

enum FilterOption {
    case startTime
    case endTime
}

extension TimePlace {
    func toDates() -> [Date] {
        let today = Date()
        let calendar = Calendar.current
        return [startTime, endTime].map { time in
            calendar.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: today)!
        }
    }
}
