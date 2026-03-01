//
//  SettingsPathType.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation
import FoundationUtility

enum SettingsPathType: Hashable {
    case myAccount
    case notificationInbox
    case appearance
    case timetableSettings
    case timetableRange
    case timetableTheme
    case vacancyNotification
    case lectureReminder
    case lectureDiary
    case themeMarket
    case developers
    case userSupport
    case termsOfService
    case privacyPolicy
    #if DEBUG
        case networkLogs
    #endif
}
