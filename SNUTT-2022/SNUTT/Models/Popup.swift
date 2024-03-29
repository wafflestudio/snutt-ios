//
//  Popup.swift
//  SNUTT
//
//  Created by 최유림 on 2022/11/04.
//

import Foundation

struct Popup: Identifiable {
    let id: String
    let imageURL: String
    let hiddenDays: Int?
    var dismissedAt: Date?
    var dontShowForWhile: Bool

    var shouldShow: Bool {
        if !dontShowForWhile {
            return dismissedAt == nil
        }
        guard let lastUpdate = dismissedAt else { return true }
        guard let hiddenDays = hiddenDays else { return false }
        return Date().daysFrom(lastUpdate) > hiddenDays
    }
}

extension Popup {
    init(from dto: PopupDto) {
        id = dto.key
        imageURL = dto.image_url
        hiddenDays = dto.hidden_days
        dismissedAt = dto.dismissed_at
        dontShowForWhile = dto.dont_show_for_while ?? false
    }
}
