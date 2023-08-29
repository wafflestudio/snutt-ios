//
//  TimePlace.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import Foundation

struct TimePlace: Identifiable {
    let id: String

    var day: Weekday

    var startTime: String

    var endTime: String

    var place: String

    let isCustom: Bool

    /// `true` if and only if this `TimePlace` object is created locally, but not committed to the server yet.
    /// This flag is necessary in order to remove `_id` field for newly created objects, before comitting to the server.
    var isTemporary: Bool = false

    var startTimeDouble: Double {
        return TimeUtils.getTimeInDouble(from: startTime)
    }

    var endTimeDouble: Double {
        endTimeDouble(compactMode: false)
    }

    func duration(compactMode: Bool) -> Double {
        return endTimeDouble(compactMode: compactMode) - startTimeDouble
    }

    func isOverlapped(with timeplace: TimePlace) -> Bool {
        return day == timeplace.day && endTime > timeplace.startTime && startTime < timeplace.endTime && id != timeplace.id
    }

    var preciseTimeString: String {
        return "\(day.veryShortSymbol)(\(startTime)~\(endTime))"
    }

    private func endTimeDouble(compactMode: Bool) -> Double {
        if compactMode && !isCustom {
            return TimeUtils.getTimeInDouble(from: endTime.roundUpForCompactMode())
        } else {
            return TimeUtils.getTimeInDouble(from: endTime)
        }
    }
}

private extension String {
    func roundUpForCompactMode() -> String {
        var time = TimeUtils.getTime(from: self)
        if time.minute > 0 && time.minute < 30 {
            time.minute = 30
        } else if time.minute > 30 {
            time.hour += 1
            time.minute = 0
        }
        return time.toString()
    }
}

extension TimePlace {
    init(from dto: TimePlaceDto, isCustom: Bool) {
        id = dto._id ?? UUID().description
        startTime = dto.start_time
        endTime = dto.end_time
        place = dto.place
        day = .init(rawValue: dto.day) ?? .mon
        self.isCustom = isCustom
    }
}

// MARK: Widget Utils

extension TimePlace {
    func toDates() -> [Date] {
        let start = TimeUtils.getTime(from: startTime)
        let end = TimeUtils.getTime(from: endTime)
        let today = Date()
        let calendar = Calendar.current
        return [start, end].map { time in
            calendar.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: today)!
        }
    }
}

#if DEBUG
    extension TimePlace {
        static var preview: Self {
            let place = "\(Int.random(in: 100 ... 999))-\(Int.random(in: 100 ... 999))"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"

            let startHour = Int.random(in: 8 ... 21) // generate a random start hour between 8am and 9pm
            let endHour = Int.random(in: (startHour + 1) ... 22) // generate a random end hour that is at least 1 hour after startHour, but before 10pm

            let startMinute = Int.random(in: 0 ... 59) // generate a random start minute
            let endMinute = Int.random(in: 0 ... 59) // generate a random end minute

            let startTime = DateComponents(hour: startHour, minute: startMinute)
            let endTime = DateComponents(hour: endHour, minute: endMinute)

            let startTimeDate = Calendar.current.date(from: startTime)!
            let endTimeDate = Calendar.current.date(from: endTime)!

            let startTimeString = dateFormatter.string(from: startTimeDate)
            let endTimeString = dateFormatter.string(from: endTimeDate)
            return TimePlace(id: UUID().uuidString,
                             day: .init(rawValue: Int.random(in: 0 ... 6))!,
                             startTime: startTimeString,
                             endTime: endTimeString,
                             place: place,
                             isCustom: Bool.random())
        }
    }
#endif
