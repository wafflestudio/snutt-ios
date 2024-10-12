//
//  TimetableUserDefaultsRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import DependenciesAdditions
import Foundation
import TimetableInterface

struct TimetableUserDefaultsRepository<ConcreteTimetable: Timetable>: TimetableLocalRepository {
    @Dependency(\.userDefaults) private var userDefaults

    func loadSelectedTimetable() throws -> any Timetable {
        let data = try userDefaults.object(forKey: Keys.selectedTimetable.rawValue, type: ConcreteTimetable.self)
        return data
    }

    func storeSelectedTimetable(_ timetable: any Timetable) throws {
        let data = try JSONEncoder().encode(timetable)
        userDefaults.set(data, forKey: Keys.selectedTimetable.rawValue)
    }

    private enum Keys: String {
        case selectedTimetable
    }
}
