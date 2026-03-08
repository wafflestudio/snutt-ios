//
//  TimetableViewModelProtocol.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Observation
import SwiftUI

@MainActor
public protocol TimetableViewModelProtocol: Observable {
    var currentTimetable: Timetable? { get }
    func setCurrentTimetable(_ timetable: Timetable) throws
}

struct DefaultTimetableViewModel: TimetableViewModelProtocol {
    var currentTimetable: Timetable?

    func setCurrentTimetable(_: Timetable) throws {}
}

extension EnvironmentValues {
    @Entry public var timetableViewModel: any TimetableViewModelProtocol = DefaultTimetableViewModel()
}
