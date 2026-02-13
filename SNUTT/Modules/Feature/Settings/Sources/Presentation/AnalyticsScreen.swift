//
//  AnalyticsScreen.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface

enum AnalyticsScreen: AnalyticsLogEvent {

    case settingsHome
    case settingsAccount
    case settingsTimetable
    case settingsColorScheme
    case settingsSupport
    case settingsDevelopers

    case vacancy

    var eventName: String {
        switch self {
        case .settingsHome:
            "settings_home"
        case .settingsAccount:
            "settings_account"
        case .settingsTimetable:
            "settings_timetable"
        case .settingsColorScheme:
            "settings_color_scheme"
        case .settingsSupport:
            "settings_support"
        case .settingsDevelopers:
            "settings_developers"
        case .vacancy:
            "vacancy"
        }
    }

    var parameters: [String: String]? { nil }
}
