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

    var startTime: TimeUtils.Time
    var endTime: TimeUtils.Time

    var startMinute: Int {
        startTime.hour * 60 + startTime.minute
    }

    var endMinute: Int {
        endTime.hour * 60 + endTime.minute
    }

    var place: String

    let isCustom: Bool

    /// `true` if and only if this `TimePlace` object is created locally, but not committed to the server yet.
    /// This flag is necessary in order to remove `_id` field for newly created objects, before comitting to the server.
    var isTemporary: Bool = false

    func duration(compactMode: Bool) -> CGFloat {
        return CGFloat(roundedEndMinute(compactMode: compactMode) - startMinute) / 60
    }

    func isOverlapped(with timeplace: TimePlace) -> Bool {
        return day == timeplace.day && endMinute > timeplace.startMinute && startMinute < timeplace.endMinute && id != timeplace.id
    }

    var preciseTimeString: String {
        return "\(day.veryShortSymbol)(\(startTime.toString())~\(endTime.toString()))"
    }

    private func roundedEndMinute(compactMode: Bool) -> Int {
        if compactMode && !isCustom {
            let rounded = endTime.roundUpForCompactMode()
            return rounded.hour * 60 + rounded.minute
        } else {
            return endMinute
        }
    }
}

extension TimeUtils.Time {
    func roundUpForCompactMode() -> Self {
        var time = self
        if time.minute > 0 && time.minute < 30 {
            time.minute = 30
        } else if time.minute > 30 {
            time.hour += 1
            time.minute = 0
        }
        return time
    }
}

extension TimePlace {
    init(from dto: TimePlaceDto, isCustom: Bool) {
        id = dto._id ?? UUID().description
        let start = dto.startMinute.quotientAndRemainder(dividingBy: 60)
        let end = dto.endMinute.quotientAndRemainder(dividingBy: 60)
        startTime = .init(hour: start.0, minute: start.1)
        endTime = .init(hour: end.0, minute: end.1)
        place = dto.place
        day = .init(rawValue: dto.day) ?? .mon
        self.isCustom = isCustom
    }
}

// MARK: Widget Utils

extension TimePlace {
    func toDates() -> [Date] {
        let today = Date()
        let calendar = Calendar.current
        return [startTime, endTime].map { time in
            calendar.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: today)!
        }
    }
}

#if DEBUG
    extension TimePlace {
        static var preview: Self {
            let place = "\(Int.random(in: 100 ... 999))-\(Int.random(in: 100 ... 999))"
            let startHour = Int.random(in: 8 ... 21) // generate a random start hour between 8am and 9pm
            let endHour = Int.random(in: (startHour + 1) ... 22) // generate a random end hour that is at least 1 hour after startHour, but before 10pm

            let startMinute = Int.random(in: 0 ... 59) // generate a random start minute
            let endMinute = Int.random(in: 0 ... 59) // generate a random end minute

            return TimePlace(id: UUID().uuidString,
                             day: .init(rawValue: Int.random(in: 0 ... 6))!,
                             startTime: .init(hour: startHour, minute: startMinute),
                             endTime: .init(hour: endHour, minute: endMinute),
                             place: place,
                             isCustom: Bool.random())
        }
    }
#endif
