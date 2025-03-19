//
//  SettingsMenu.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation
import SwiftUI

enum Settings: MenuItem {
    case myAccount(_ nickname: String)
    case appearance(_ mode: String)
    case appLanguage
    case timetableSettings
    case timetableTheme
    case vacancyNotification
    case themeMarket
    case version(_ version: String)
    case developers
    case shareFeedback
    case openSourceLicense
    case termsOfService
    case privacyPolicy
    case networkLogs
    case logout

    var title: String {
        switch self {
        case .myAccount:
            SettingsStrings.account
        case .appearance:
            SettingsStrings.displayColorMode
        case .appLanguage:
            SettingsStrings.displayLanguage
        case .timetableSettings:
            SettingsStrings.displayTable
        case .timetableTheme:
            SettingsStrings.displayTheme
        case .vacancyNotification:
            SettingsStrings.serviceVacancy
        case .themeMarket:
            SettingsStrings.serviceThemeMarket
        case .version:
            SettingsStrings.infoVersion
        case .developers:
            SettingsStrings.infoDevelopers
        case .shareFeedback:
            SettingsStrings.feedback
        case .openSourceLicense:
            SettingsStrings.license
        case .termsOfService:
            SettingsStrings.termsService
        case .privacyPolicy:
            SettingsStrings.privacyPolicy
        case .networkLogs:
            SettingsStrings.debugLog
        case .logout:
            SettingsStrings.logout
        }
    }

    var leadingImage: Image? {
        switch self {
        case .myAccount: SettingsAsset.person.swiftUIImage
        default: nil
        }
    }

    var detail: String? {
        switch self {
        case let .myAccount(nickname): nickname
        case let .appearance(mode): mode
        case let .version(version): version
        default: nil
        }
    }

    var detailImage: Image? {
        nil
    }

    var destructive: Bool {
        switch self {
        case .logout: true
        default: false
        }
    }

    var shouldNavigate: Bool {
        switch self {
        case .version, .logout: false
        default: true
        }
    }
}
