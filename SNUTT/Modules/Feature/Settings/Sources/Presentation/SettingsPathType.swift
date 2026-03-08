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
    case pushNotificationSettings
    case vacancyNotification
    case lectureReminder
    #if FEATURE_LECTURE_DIARY
        case lectureDiary
    #endif
    case themeMarket
    case developers
    case userSupport
    case termsOfService
    case privacyPolicy
    #if DEBUG
        case networkLogs
    #endif
}
