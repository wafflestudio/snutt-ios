//
//  TimetableConfiguration.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/23.
//

import Foundation

struct TimetableConfiguration: Codable {
    var minHour: Int = 9
    var maxHour: Int = 18
    var autoFit: Bool = true

    var visibleWeeks: [Weekday] = [.mon, .tue, .wed, .thu, .fri]
    
    var visibleWeeksSorted: [Weekday] {
        var weekdayOrder: [Weekday: Int] = [:]
        Weekday.allCases.enumerated().forEach { offset, element in
            weekdayOrder[element] = offset
        }
        return visibleWeeks
            .sorted { weekdayOrder[$0]! < weekdayOrder[$1]! }
    }

    var weekCount: Int {
        visibleWeeks.count
    }

    func withAutoFitEnabled() -> Self {
        var this = self
        this.autoFit = true
        return this
    }

    var isWidget: Bool {
        #if WIDGET
            true
        #else
            false
        #endif
    }
}
