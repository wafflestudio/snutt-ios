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

struct TimetableUserDefaultsRepository<ConcreteTimetable: Timetable>: TimetableLocalRepository {
    @Dependency(\.userDefaults) private var userDefaults

    func loadSelectedTimetable() throws -> any Timetable {
        try userDefaults.object(forKey: Keys.currentTimetable.rawValue, type: ConcreteTimetable.self)
    }

    func storeSelectedTimetable(_ timetable: any Timetable) throws {
        let data = try JSONEncoder().encode(timetable)
        userDefaults.set(data, forKey: Keys.currentTimetable.rawValue)
        storeWidgetTimetable(timetable)
    }

    func loadTimetableConfiguration() -> TimetableConfiguration {
        userDefaults[\.timetableConfiguration]
    }

    func storeTimetableConfiguration(_ configuration: TimetableConfiguration) {
        userDefaults[\.timetableConfiguration] = configuration
    }

    private enum Keys: String {
        case currentTimetable
        case widgetTimetable
    }
}

extension TimetableUserDefaultsRepository {
    private func storeWidgetTimetable(_ timetable: any Timetable) {
        let previewTimetable = PreviewTimetable(
            id: timetable.id,
            title: timetable.title,
            quarter: timetable.quarter,
            previewLectures: timetable.lectures.map {
                PreviewLecture(
                    id: $0.id, lectureID: $0.lectureID, courseTitle: $0.courseTitle, timePlaces: $0.timePlaces, lectureNumber: $0.lectureNumber, instructor: $0.instructor, credit: $0.credit, courseNumber: $0.courseNumber, department: $0.department, academicYear: $0.academicYear, evLecture: $0.evLecture, classification: $0.classification, category: $0.category, quota: $0.quota, freshmenQuota: $0.freshmenQuota
                )
            },
            userID: timetable.userID
        )
        let data = try? JSONEncoder().encode(previewTimetable)
        userDefaults.set(data, forKey: Keys.widgetTimetable.rawValue)
    }
}

extension UserDefaultsEntryDefinitions {
    var timetableConfiguration: UserDefaultsEntry<TimetableConfiguration> {
        UserDefaultsEntry(key: "timetableConfiguration", defaultValue: TimetableConfiguration())
    }
}
