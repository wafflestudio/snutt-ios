//
//  HighlightOnPress.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder public func highlightOnPress(
        precondition: Bool = true,
        scale: CGFloat = 0.98,
        backgroundColor: Color = .clear
    ) -> some View {
        if precondition {
            modifier(HighlightModifier(scale: scale, backgroundColor: backgroundColor))
        } else {
            self
        }
    }
}

private struct HighlightModifier: ViewModifier {
    let scale: CGFloat
    let backgroundColor: Color
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if isPressed {
                        backgroundColor
                    } else {
                        Color.clear
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .padding(.horizontal, -5)
            )
            .scaleEffect(isPressed ? scale : 1)
            .animation(.defaultSpring, value: isPressed)
            .onLongPressGesture(
                minimumDuration: 0,
                perform: {},
                onPressingChanged: {
                    isPressed = $0
                }
            )
    }
}
