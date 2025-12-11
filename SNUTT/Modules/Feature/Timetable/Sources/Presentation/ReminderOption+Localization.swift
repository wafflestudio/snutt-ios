//
//  ReminderOption+Localization.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation

extension ReminderOption {
    /// Localized label for the option
    var label: String {
        switch self {
        case .disabled:
            return TimetableStrings.reminderOptionNone
        case .before10:
            return TimetableStrings.reminderOptionBefore10
        case .onTime:
            return TimetableStrings.reminderOptionOnTime
        case .after10:
            return TimetableStrings.reminderOptionAfter10
        }
    }

    /// Toast message to display when this option is selected
    var toastMessage: String? {
        switch self {
        case .disabled:
            return nil
        case .before10:
            return TimetableStrings.reminderToastBefore10
        case .onTime:
            return TimetableStrings.reminderToastOnTime
        case .after10:
            return TimetableStrings.reminderToastAfter10
        }
    }
}
