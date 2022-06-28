//
//  DrawingSetting.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import SwiftUI

class TimetableSetting: ObservableObject {
    let minHour: Int = 8
    let maxHour: Int = 19

    let visibleWeeks: [Weekday] = [.mon, .tue, .wed, .thu, .fri]

    var hourCount: Int {
        maxHour - minHour + 1
    }

    var weekCount: Int {
        visibleWeeks.count
    }
}
