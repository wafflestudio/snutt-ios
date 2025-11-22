//
//  SettingsPathType.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation
import FoundationUtility

enum SettingsPathType: Hashable {
    case myAccount
    case appearance
    case timetableSettings
    case timetableRange
    case timetableTheme
    case vacancyNotification
    case lectureReminder
    case themeMarket
    case developers
    case userSupport
    case termsOfService
    case privacyPolicy
    #if DEBUG
        case networkLogs
    #endif
}
