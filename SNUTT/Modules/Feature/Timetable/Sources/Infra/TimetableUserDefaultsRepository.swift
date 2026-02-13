//
//  TimetableUserDefaultsRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import DependenciesUtility
import Foundation
import TimetableInterface
import TimetableUIComponents

struct TimetableUserDefaultsRepository: TimetableLocalRepository {
    @Dependency(\.userDefaults) private var userDefaults
    @Dependency(\.widgetReloader) private var widgetReloader

    func loadSelectedTimetable() throws -> Timetable {
        try userDefaults.object(forKey: TimetableUserDefaultsKeys.currentTimetable.rawValue, type: Timetable.self)
    }

    func storeSelectedTimetable(_ timetable: Timetable) throws {
        let data = try JSONEncoder().encode(timetable)
        userDefaults.set(data, forKey: TimetableUserDefaultsKeys.currentTimetable.rawValue)
        widgetReloader.reloadAll()
    }

    func loadTimetableConfiguration() -> TimetableConfiguration {
        userDefaults[\.timetableConfiguration]
    }

    func storeTimetableConfiguration(_ configuration: TimetableConfiguration) {
        userDefaults[\.timetableConfiguration] = configuration
        widgetReloader.reloadAll()
    }

    func configurationValues() -> AsyncStream<TimetableConfiguration> {
        userDefaults.dataValues(forKey: TimetableUserDefaultsKeys.timetableConfiguration.rawValue).compactMap {
            guard let data = $0 else { return nil }
            return try? JSONDecoder().decode(TimetableConfiguration.self, from: data)
        }.eraseToStream()
    }
}

extension UserDefaultsEntryDefinitions {
    var timetableConfiguration: UserDefaultsEntry<TimetableConfiguration> {
        UserDefaultsEntry(
            key: TimetableUserDefaultsKeys.timetableConfiguration.rawValue,
            defaultValue: TimetableConfiguration()
        )
    }
}
