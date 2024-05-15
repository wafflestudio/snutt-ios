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
    private(set) var dismissedAt: Date?
    private(set) var dontShowForWhile: Bool

    var shouldShow: Bool {
        if !dontShowForWhile { return dismissedAt == nil }
        guard let dismissedAt = dismissedAt else { return true }
        guard let hiddenDays = hiddenDays else {
            // if `hiddenDays` is nil, never show the popup again
            return false
        }
        return Date().daysFrom(dismissedAt) >= hiddenDays
    }
    
    mutating func markAsDismissed(dontShowForWhile: Bool) {
        self.dismissedAt = Date()
        // if `hiddenDays` is 0, always show the popup next time
        if hiddenDays == 0 {
            self.dontShowForWhile = false
            return
        }
        self.dontShowForWhile = dontShowForWhile
    }
    
    mutating func resetDismissedAt() -> Self {
        if dontShowForWhile { return self }
        dismissedAt = nil
        return self
    }
}

extension Popup {
    init(from dto: PopupDto) {
        id = dto.key
        imageURL = dto.imageUri
        hiddenDays = dto.hiddenDays
        dismissedAt = nil
        dontShowForWhile = false
    }

    init(from metadata: PopupMetadata, imageUri: String) {
        id = metadata.key
        imageURL = imageUri
        hiddenDays = metadata.hiddenDays
        dismissedAt = metadata.dismissedAt
        dontShowForWhile = metadata.dontShowForWhile ?? false
    }
}
