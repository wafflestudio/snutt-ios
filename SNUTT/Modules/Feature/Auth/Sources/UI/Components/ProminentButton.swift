//
//  ProminentButton.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
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
        AnimatableButton(
            animationOptions: .identity.impact().backgroundColor(touchDown: .black.opacity(0.05)).scale(0.97),
            layoutOptions: [.respectIntrinsicHeight, .expandHorizontally]
        ) {
            action()
        } configuration: { button in
            button.isEnabled = isEnabled
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = .init(
                label,
                attributes: .init().font(font)
            )
            configuration.cornerStyle = .large
            configuration.baseForegroundColor = .init(foregroundColor)
            configuration.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
            configuration.background.backgroundColor =
                isEnabled
                ? .init(backgroundColor)
                : .init(backgroundColorDisabled)
            return configuration
        }
    }
}
