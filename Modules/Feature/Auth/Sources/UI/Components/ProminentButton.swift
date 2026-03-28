//
//  ProminentButton.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct ProminentButton: View {
    let label: String
    var isEnabled: Bool = true
    var font: UIFont = .systemFont(ofSize: 17, weight: .semibold)
    var foregroundColor: Color = .white
    var backgroundColor: Color = SharedUIComponentsAsset.cyan.swiftUIColor
    var backgroundColorDisabled: Color = Color(uiColor: .tertiarySystemFill)
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
                .font(Font(font))
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isEnabled ? backgroundColor : backgroundColorDisabled)
                )
        }
        .disabled(!isEnabled)
        .buttonStyle(
            .animatable(scale: 0.97, backgroundHighlightColor: Color(.label).opacity(0.05), hapticFeedback: true)
        )
    }
}
