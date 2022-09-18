//
//  TimetableConfiguration.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/23.
//

import Foundation

struct TimetableConfiguration: Codable {
    var minHour: Int = 8
    var maxHour: Int = 19
    var autoFit: Bool = true

    var visibleWeeks: [Weekday] = [.mon, .tue, .wed, .thu, .fri]

    var hourCount: Int {
        maxHour - minHour + 1
    }

    var weekCount: Int {
        visibleWeeks.count
    }
}
