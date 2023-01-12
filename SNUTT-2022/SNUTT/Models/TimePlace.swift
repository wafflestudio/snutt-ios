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

#if DEBUG
    extension TimePlace {
        static var preview: Self {
            let place = "\(Int.random(in: 100 ... 999))-\(Int.random(in: 100 ... 999))"
            return TimePlace(id: UUID().uuidString,
                             day: .init(rawValue: Int.random(in: 0 ... 6))!,
                             startTime: "15:00",
                             endTime: "18:15",
                             place: place,
                             isCustom: Bool.random())
        }
    }
#endif
