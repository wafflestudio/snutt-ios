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

    
    private let start: Double

    /// 단위: 시간
    ///
    /// - TODO: 서버에서 내려주는 시간은 0.5의 배수이다. 따라서 강의가 끝나는 시각을 정확하게 나타내기 위해서는 적절한 보정이 필요하다.
    let len: Double

    let place: String
    
    let isCustom: Bool
    
    /// 단위: 교시
    ///
    /// 정규 강좌의 경우(`isCustom == false`), 7.5교시는 오후 15시 30분을 의미한다.
    /// 그러나 커스텀 강좌의 경우(`isCustom == true`), 7.5교시는 오전 7시 30분을 의미한다.
    var startTime: Double {
        isCustom ? start : start + 8
    }

    var endTime: Double {
        startTime + len
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
