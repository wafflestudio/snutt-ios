//
//  PopupModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation
import FoundationUtility

struct PopupModel: Sendable, Identifiable {
    var id: String { key }
    let key: String

    /// Indicates whether the popup is dismissed by the user in the current session.
    var isDismissed = false

    init(serverPopup: ServerPopup, localPopup: LocalPopup? = nil) {
        key = serverPopup.key
        self.serverPopup = serverPopup
        self.localPopup = localPopup
    }

    var imageURL: URL? {
        URL(string: serverPopup.imageUri)
    }

    private let serverPopup: ServerPopup
    var localPopup: LocalPopup?

    var shouldShow: Bool {
        if isDismissed {
            // The user dismissed the popup in the current session
            return false
        }
        guard let dismissInfo = localPopup?.dismissInfo else {
            // The user has never dismissed the popup yet
            return true
        }
        if !dismissInfo.dontShowForWhile {
            // The user dismissed the popup, but didn't ask to hide it for a while
            return true
        }
        guard let hiddenDays = dismissInfo.hiddenDays else {
            // If `hiddenDays` is nil, never show the popup again
            return false
        }
        return Date().daysFrom(dismissInfo.dismissedAt) >= hiddenDays
    }

    mutating func markAsDismissed(dontShowForWhile: Bool) {
        isDismissed = true
        if serverPopup.hiddenDays == 0 {
            // If `hiddenDays` is 0, always show the popup next time
            localPopup = .init(
                key: key,
                dismissInfo: .init(hiddenDays: serverPopup.hiddenDays, dismissedAt: .now, dontShowForWhile: false)
            )
            return
        }
        localPopup = .init(
            key: key,
            dismissInfo: .init(
                hiddenDays: serverPopup.hiddenDays,
                dismissedAt: .now,
                dontShowForWhile: dontShowForWhile
            )
        )
    }
}
