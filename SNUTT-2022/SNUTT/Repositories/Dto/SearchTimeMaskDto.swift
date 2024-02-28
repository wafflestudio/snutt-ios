//
//  SearchTimeMaskDto.swift
//  SNUTT
//
//  Created by 최유림 on 2024/02/09.
//

import Foundation

struct SearchTimeMaskDto: Codable, Hashable {
    let day: Int
    let startMinute: Int
    let endMinute: Int
}

extension SearchTimeMaskDto {
    var preciseTimeString: String {
        return "\(Weekday(rawValue: day)!.veryShortSymbol) \(TimeUtils.Time(hour: startMinute / 60, minute: startMinute % 60).toString())-\(TimeUtils.Time(hour: endMinute / 60, minute: endMinute % 60).toString())"
    }
}
