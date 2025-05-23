//
//  ThemeUIProvider.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
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
}
