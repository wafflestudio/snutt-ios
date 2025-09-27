//
//  TimetableConfiguration.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation
import FoundationUtility
import MemberwiseInit
import TimetableInterface

extension TimetableConfiguration {
    var visibleWeeksSorted: [Weekday] {
        visibleWeeks.sorted { $0.rawValue < $1.rawValue }
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
        false
    }
}
