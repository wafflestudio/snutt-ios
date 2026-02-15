//
//  LocalPopup.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation

struct LocalPopup: Codable, Identifiable, Sendable {
    var id: String { key }
    let key: String
    let dismissInfo: DismissInfo

    struct DismissInfo: Codable, Sendable {
        let hiddenDays: Int?
        let dismissedAt: Date
        let dontShowForWhile: Bool
    }
}
