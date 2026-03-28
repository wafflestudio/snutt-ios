//
//  ActionSheetItem.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct ActionSheetItem: Identifiable {
    public let id = UUID()
    public let image: Image?
    public let title: String
    public let role: ActionSheetLabel.Role
    public let action: @MainActor () -> Void

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
