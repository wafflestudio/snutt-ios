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
    var compactMode: Bool = false

    var visibleWeeks: [Weekday] = [.mon, .tue, .wed, .thu, .fri]

    var visibleWeeksSorted: [Weekday] {
        var weekdayOrder: [Weekday: Int] = [:]
        for (offset, element) in Weekday.allCases.enumerated() {
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

    func withTimeRangeSelectionMode() -> Self {
        var this = self
        this.visibleWeeks = [.mon, .tue, .wed, .thu, .fri]
        this.autoFit = false
        this.compactMode = true
        this.minHour = 8
        this.maxHour = 22
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
