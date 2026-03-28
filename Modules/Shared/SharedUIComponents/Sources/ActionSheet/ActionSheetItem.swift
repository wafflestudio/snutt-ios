//
//  ActionSheetItem.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct ActionSheetItem: Identifiable, Sendable {
    public var id: String { title }
    let image: Image?
    let title: String
    let role: ActionSheetLabel.Role
    let action: @MainActor () -> Void

    public init(
        image: Image? = nil,
        title: String,
        role: ActionSheetLabel.Role = .normal,
        action: @MainActor @escaping () -> Void
    ) {
        self.image = image
        self.title = title
        self.role = role
        self.action = action
    }
}
