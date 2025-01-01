//
//  HighlightOnPress.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

extension View {
    public func highlightOnPress(scale: CGFloat = 0.98) -> some View {
        modifier(HighlightModifier(scale: scale))
    }
}

private struct HighlightModifier: ViewModifier {
    let scale: CGFloat
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .background(
                Color.label.opacity(isPressed ? 0.1 : 0)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .padding(.horizontal, -5)
            )
            .scaleEffect(isPressed ? scale : 1)
            .animation(.defaultSpring, value: isPressed)
            .onLongPressGesture(minimumDuration: 0, perform: {}, onPressingChanged: {
                isPressed = $0
            })

    }
}
