//
//  TimetableState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import SwiftUI

class TimetableState: ObservableObject {
    @Published var current: Timetable?
    @Published var metadataList: [TimetableMetadata]?
    @Published var configuration: TimetableConfiguration = .init()
}

struct TimetableConfiguration {
    var minHour: Int = 8
    var maxHour: Int = 19

    var visibleWeeks: [Weekday] = [.mon, .tue, .wed, .thu, .fri, .sat]

    var hourCount: Int {
        maxHour - minHour + 1
    }

    var weekCount: Int {
        visibleWeeks.count
    }
}
