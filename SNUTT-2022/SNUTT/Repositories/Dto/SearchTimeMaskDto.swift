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
