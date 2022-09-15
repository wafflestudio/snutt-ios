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

    /// 단위: 교시
    var start: Double

    /// 단위: 시간
    ///
    /// - TODO: 서버에서 내려주는 시간은 0.5의 배수이다. 따라서 강의가 끝나는 시각을 정확하게 나타내기 위해서는 적절한 보정이 필요하다.
    var len: Double

    var place: String

    let isCustom: Bool
    
    /// `true` if and only if this `TimePlace` object is created locally, but not committed to the server yet.
    /// This flag is necessary in order to remove `_id` field for newly created objects, before comitting to the server.
    var isTemporary: Bool = false

    /// 단위: 시각
    ///
    /// 7.5교시는 오후 15시 30분을 의미한다.
    var startTime: Double {
        get { start + 8 }
        set { start = newValue - 8}
    }

    var endTime: Double {
        startTime + len
    }

    var startTimeString: String {
        TimeUtils.getPreciseHourMinuteString(from: startTime)
    }

    var endTimeString: String {
        TimeUtils.getPreciseHourMinuteString(from: endTime)
    }

    /// `월7`(월요일 7교시)과 같이 표기한다.
    var startDateTimeString: String {
        TimeUtils.getStartDateTimeString(day: day, classPeriod: start)
    }
}

extension TimePlace {
    init(from dto: TimePlaceDto, isCustom: Bool) {
        id = dto._id ?? UUID().description
        start = dto.start
        len = dto.len
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
                             start: Double.random(in: 1 ... 8),
                             len: Double.random(in: 0 ... 3),
                             place: place,
                             isCustom: Bool.random())
        }
    }
#endif
