//
//  UnderlineButton.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct UnderlineButton: View {
    let label: String
    let action: () -> Void

    private enum Design {
        static let fontColor = UIColor.secondaryLabel
    }

    var body: some View {
        AnimatableButton(
            animationOptions: .identity.scale(0.95),
            layoutOptions: [.respectIntrinsicWidth, .respectIntrinsicHeight]
        ) {
            action()
        } configuration: { _ in
            var configuration = UIButton.Configuration.plain()
            configuration.baseBackgroundColor = SharedUIComponentsAsset.cyan.color
            configuration.baseForegroundColor = Design.fontColor
            let attributes: [NSAttributedString.Key: Any] = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: Design.fontColor,
                .font: UIFont.systemFont(ofSize: 14),
            ]
            configuration.contentInsets = .zero
            configuration.attributedTitle = .init(label, attributes: AttributeContainer(attributes))
            return configuration
        }
    }
}
