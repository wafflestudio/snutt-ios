//
//  TimetableViewModelProtocol.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Observation
import SwiftUI

@MainActor
public protocol TimetableViewModelProtocol: Observable {
    var currentTimetable: Timetable? { get }
}

struct DefaultTimetableViewModel: TimetableViewModelProtocol {
    var currentTimetable: Timetable?
}

extension EnvironmentValues {
    @Entry public var timetableViewModel: any TimetableViewModelProtocol = DefaultTimetableViewModel()
}
