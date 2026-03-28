//
//  ThemeUIProvider.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import SwiftUI
import ThemesInterface

@MainActor
public struct ThemeUIProvider: ThemeUIProvidable {
    public nonisolated init() {}
    public func menuThemeSelectionSheet() -> AnyView {
        AnyView(MenuThemeSelectionSheet())
    }

    public func themeMarketScene() -> AnyView {
        AnyView(ThemeMarketScene())
    }

    public func themeSettingsScene() -> AnyView {
        AnyView(ThemeSettingsScene())
    }
}
