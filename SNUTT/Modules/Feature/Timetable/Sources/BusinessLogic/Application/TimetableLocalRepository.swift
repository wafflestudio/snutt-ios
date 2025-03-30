//
//  TimetableLocalRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable
import TimetableInterface

@Spyable
protocol TimetableLocalRepository: Sendable {
    func loadSelectedTimetable() throws -> Timetable
    func storeSelectedTimetable(_ timetable: Timetable) throws
}
