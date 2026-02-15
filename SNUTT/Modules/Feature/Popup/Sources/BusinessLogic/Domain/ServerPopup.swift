//
//  ServerPopup.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation

struct ServerPopup: Sendable, Identifiable {
    var id: String { key }
    let key: String
    let imageUri: String
    let linkURL: URL?
    let hiddenDays: Int?
}
