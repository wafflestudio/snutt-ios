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
    associatedtype ConcreteTimetable
    func loadSelectedTimetable() throws -> any Timetable
    func storeSelectedTimetable(_ timetable: any Timetable) throws
}
