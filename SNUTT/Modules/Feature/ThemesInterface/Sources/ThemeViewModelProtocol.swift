//
//  ThemeViewModelProtocol.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Observation
import SwiftUI

@MainActor
public protocol ThemeViewModelProtocol: Observable {
    var availableThemes: [Theme] { get }
    var selectedTheme: Theme? { get }
    func selectTheme(_ theme: Theme?)
    func saveSelectedTheme() async throws
}

struct DefaultThemeViewModel: ThemeViewModelProtocol {
    var availableThemes: [Theme] = []
    var selectedTheme: Theme? = nil
    func selectTheme(_: Theme?) {}
    func saveSelectedTheme() async throws {}
}

extension EnvironmentValues {
    @Entry public var themeViewModel: any ThemeViewModelProtocol = DefaultThemeViewModel()
}
