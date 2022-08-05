//
//  TimePlace.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import Foundation

struct TimePlace: Identifiable {
    let id: String

    let day: Weekday

    /// 단위: 교시
    var start: Double

    /// 단위: 시간
    ///
    /// - TODO: 서버에서 내려주는 시간은 0.5의 배수이다. 따라서 강의가 끝나는 시각을 정확하게 나타내기 위해서는 적절한 보정이 필요하다.
    var len: Double

    var place: String

    let isCustom: Bool

    /// 단위: 시각
    ///
    /// 7.5교시는 오후 15시 30분을 의미한다.
    var startTime: Double {
        start + 8
    }

    var endTime: Double {
        startTime + len
    }

    var startTimeString: String {
        getString(from: startTime)
    }

    var endTimeString: String {
        getString(from: endTime)
    }

    /// `월7`(월요일 7교시)과 같이 표기한다.
    var startDateTimeString: String {
        "\(day.shortSymbol)\(Int(start))"
    }

    /// `time: Double`을 분 단위로 정확하게 60진법 수로 환산한다.
    /// ex) 15.3 -> 15시 18분(`0.3 * 60 == 18`)
    private func getString(from time: Double) -> String {
        let hour = Int(time)
        let minute: Double = (time.truncatingRemainder(dividingBy: 1) * 60).rounded() // schoolbook rounding
        return "\(hour):\(String(format: "%02d", Int(minute)))"
    }
}

extension TimePlace {
    init(from dto: TimePlaceDto, isCustom: Bool) {
        id = dto._id
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
