//
//  SNUTTWidgetDataSource.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import DependenciesUtility
import Dependencies
import DependenciesAdditions
import Foundation
import TimetableInterface
import TimetableUIComponents

final class SNUTTWidgetDataSource {
    private let userDefaults: UserDefaults.Dependency
    init() {
        @Dependency(\.bundleInfo) var bundleInfo
        let appGroupSuiteName = "group.\(bundleInfo.bundleIdentifier.replacingOccurrences(of: ".widget", with: ""))"
        userDefaults = .init(suitename: appGroupSuiteName) ?? .standard
    }

    var currentTimetable: (any Timetable)? {
        guard let data = userDefaults.data(forKey: "widgetTimetable"),
              let timetable = try? JSONDecoder().decode(PreviewTimetable.self, from: data)
        else { return nil }
        return timetable
    }

    var timetableConfiguration: TimetableConfiguration {
        guard let data = userDefaults.data(forKey: "timetableConfiguration"),
              let configuration = try? JSONDecoder().decode(TimetableConfiguration.self, from: data)
        else { return .init() }
        return configuration
    }
}
