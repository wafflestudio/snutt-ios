//
//  TimePlace.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import Foundation

struct TimePlace: Codable, Identifiable {
    var id = UUID()
    
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
