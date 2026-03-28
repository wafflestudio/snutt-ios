//
//  ActionSheetButtonStyle.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct ActionSheetButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(.label).opacity(configuration.isPressed ? 0.05 : 0))
            )
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
