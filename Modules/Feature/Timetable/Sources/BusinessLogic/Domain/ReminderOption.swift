//
//  ReminderOption.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation

/// Represents the timing option for a lecture reminder notification
public enum ReminderOption: CaseIterable, Equatable, Sendable {
    case disabled
    case before10
    case onTime
    case after10
}
