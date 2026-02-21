//
//  AdaptiveColorStyles.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

extension View {
    /// Applies a light or dark foreground style based on the current color scheme.
    public func foregroundStyle(light: Color, dark: Color) -> some View {
        modifier(ForegroundStyleModifier(lightModeColor: light, darkModeColor: dark))
    }

    /// Applies a light or dark background style based on the current color scheme.
    public func backgroundStyle(light: Color, dark: Color) -> some View {
        modifier(BackgroundStyleModifier(lightModeColor: light, darkModeColor: dark))
    }

    /// Applies a light or dark capsule style with stroke based on the current color scheme.
    public func overlayCapsuleStyle(light: Color, dark: Color) -> some View {
        modifier(OverlayCapsuleStyleModifier(lightModeColor: light, darkModeColor: dark))
    }
}

private struct ForegroundStyleModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    let lightModeColor: Color
    let darkModeColor: Color

    func body(content: Content) -> some View {
        content.foregroundStyle(
            colorScheme == .dark
                ? darkModeColor
                : lightModeColor
        )
    }
}

private struct BackgroundStyleModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    let lightModeColor: Color
    let darkModeColor: Color

    func body(content: Content) -> some View {
        content.background(
            colorScheme == .dark
                ? darkModeColor
                : lightModeColor
        )
    }
}

private struct OverlayCapsuleStyleModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    let lightModeColor: Color
    let darkModeColor: Color

    func body(content: Content) -> some View {
        content.overlay(
            Capsule().stroke(
                colorScheme == .dark
                    ? darkModeColor
                    : lightModeColor
            )
        )
    }
}
