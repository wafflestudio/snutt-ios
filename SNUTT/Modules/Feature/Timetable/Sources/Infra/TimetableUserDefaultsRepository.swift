//
//  TimetableUserDefaultsRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import DependenciesUtility
import Foundation
import TimetableInterface
import TimetableUIComponents

struct TimetableUserDefaultsRepository: TimetableLocalRepository {
    @Dependency(\.userDefaults) private var userDefaults

    func loadSelectedTimetable() throws -> Timetable {
        try userDefaults.object(forKey: Keys.currentTimetable.rawValue, type: Timetable.self)
    }

    func storeSelectedTimetable(_ timetable: Timetable) throws {
        let data = try JSONEncoder().encode(timetable)
        userDefaults.set(data, forKey: Keys.currentTimetable.rawValue)
    }

    func loadTimetableConfiguration() -> TimetableConfiguration {
        userDefaults[\.timetableConfiguration]
    }

    func storeTimetableConfiguration(_ configuration: TimetableConfiguration) {
        userDefaults[\.timetableConfiguration] = configuration
    }

    func configurationValues() -> AsyncStream<TimetableConfiguration> {
        userDefaults.dataValues(forKey: "timetableConfiguration").compactMap {
            guard let data = $0 else { return nil }
            return try? JSONDecoder().decode(TimetableConfiguration.self, from: data)
        }.eraseToStream()
    }

    private enum Keys: String {
        case currentTimetable
    }
}

extension UserDefaultsEntryDefinitions {
    var timetableConfiguration: UserDefaultsEntry<TimetableConfiguration> {
        UserDefaultsEntry(key: "timetableConfiguration", defaultValue: TimetableConfiguration())
    }
}
