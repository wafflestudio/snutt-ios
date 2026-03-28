//
//  AnimatableButtonStyle.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct AnimatableButtonStyle: ButtonStyle {
    public var scale: CGFloat
    public var backgroundHighlightColor: Color?
    public var hapticFeedback: Bool
    public var animation: Animation

    public init(
        scale: CGFloat = 0.95,
        backgroundHighlightColor: Color? = nil,
        hapticFeedback: Bool = false,
        animation: Animation = .easeInOut(duration: 0.1)
    ) {
        self.scale = scale
        self.backgroundHighlightColor = backgroundHighlightColor
        self.hapticFeedback = hapticFeedback
        self.animation = animation
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .background(
                backgroundHighlightColor.map { color in
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(color.opacity(configuration.isPressed ? 1 : 0))
                }
            )
            .animation(animation, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed && hapticFeedback {
                    UISelectionFeedbackGenerator().selectionChanged()
                }
            }
    }
}

extension ButtonStyle where Self == AnimatableButtonStyle {
    public static var animatable: AnimatableButtonStyle { .init() }

    public static func animatable(
        scale: CGFloat = 0.95,
        backgroundHighlightColor: Color? = nil,
        hapticFeedback: Bool = false,
        animation: Animation = .easeInOut(duration: 0.1)
    ) -> AnimatableButtonStyle {
        .init(
            scale: scale,
            backgroundHighlightColor: backgroundHighlightColor,
            hapticFeedback: hapticFeedback,
            animation: animation
        )
    }
}
