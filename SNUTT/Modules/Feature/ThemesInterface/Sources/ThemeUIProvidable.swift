//
//  ThemeUIProvidable.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import SwiftUI

@MainActor
public protocol ThemeUIProvidable: Sendable {
    func menuThemeSelectionSheet() -> AnyView
    func themeMarketScene() -> AnyView
    func themeSettingsScene() -> AnyView
}

private struct EmptyThemeUIProvider: ThemeUIProvidable {
    func menuThemeSelectionSheet() -> AnyView {
        AnyView(Text("Empty ThemeUIProvider"))
    }

    func themeMarketScene() -> AnyView {
        AnyView(Text("Empty ThemeUIProvider"))
    }

    func themeSettingsScene() -> AnyView {
        AnyView(Text("Empty ThemeUIProvider"))
    }
}

public enum ThemeUIProviderKey: TestDependencyKey {
    public static let testValue: any ThemeUIProvidable = EmptyThemeUIProvider()
}

extension DependencyValues {
    fileprivate var themeUIProvider: any ThemeUIProvidable {
        get { self[ThemeUIProviderKey.self] }
        set { self[ThemeUIProviderKey.self] = newValue }
    }
}

extension EnvironmentValues {
    public var themeUIProvider: any ThemeUIProvidable {
        withDependencies {
            $0.context = .live
        } operation: {
            Dependency(\.themeUIProvider).wrappedValue
        }
    }
}
