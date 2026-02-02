//
//  SNUTTWidgetDataSource.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import DependenciesAdditions
import DependenciesUtility
import Foundation
import ThemesInterface
import TimetableInterface
import TimetableUIComponents

final class SNUTTWidgetDataSource {
    private let userDefaults: UserDefaults.Dependency
    init() {
        @Dependency(\.bundleInfo) var bundleInfo
        let appGroupSuiteName = "group.\(bundleInfo.bundleIdentifier.replacingOccurrences(of: ".widget", with: ""))"
        userDefaults = .init(suitename: appGroupSuiteName) ?? .standard
    }

    var currentTimetable: Timetable? {
        guard let data = userDefaults.data(forKey: "currentTimetable"),
            let timetable = try? JSONDecoder().decode(Timetable.self, from: data)
        else { return nil }
        return timetable
    }

    var timetableConfiguration: TimetableConfiguration {
        guard let data = userDefaults.data(forKey: "timetableConfiguration"),
            let configuration = try? JSONDecoder().decode(TimetableConfiguration.self, from: data)
        else { return .init() }
        return configuration
    }

    var availableThemes: [Theme] {
        guard let data = userDefaults.data(forKey: "availableThemes"),
            let themes = try? JSONDecoder().decode([Theme].self, from: data)
        else { return [] }
        return themes
    }
}
