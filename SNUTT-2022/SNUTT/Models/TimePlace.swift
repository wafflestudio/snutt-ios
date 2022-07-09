//
//  TimePlace.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import Foundation

struct TimePlace: Identifiable {
    var id: String

    var day: Weekday

    /// 단위: 교시
    ///
    /// 예를 들어, 7.5교시는 15시 30분으로 나타낸다.
    var start: Double

    /// 단위: 시간
    ///
    /// - TODO: 서버에서 내려주는 시간은 0.5의 배수이다. 따라서 강의가 끝나는 시각을 정확하게 나타내기 위해서는 적절한 보정이 필요하다.
    var len: Double

    var place: String
    
    

    var startTime: Double {
        start + 8
    }

    var endTime: Double {
        startTime + len
    }
}

extension TimePlace {
    init(from dto: TimePlaceDto) {
        id = dto._id
        start = dto.start
        len = dto.len
        place = dto.place
        day = .init(rawValue: dto.day) ?? .mon
    }
}


#if DEBUG
extension TimePlace {
    static var preview: Self {
        let place = "\(Int.random(in: 100...999))-\(Int.random(in: 100...999))"
        return TimePlace(id: UUID().uuidString, day: .init(rawValue: Int.random(in: 0...6))!, start:Double.random(in: 1...8), len: Double.random(in: 0...3), place: place)
    }
}
#endif
