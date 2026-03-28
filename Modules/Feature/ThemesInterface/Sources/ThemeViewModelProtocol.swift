//
//  ThemeViewModelProtocol.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Observation
import SwiftUI

@MainActor
public protocol ThemeViewModelProtocol: Observable {
    var availableThemes: [Theme] { get }
    var selectedTheme: Theme? { get }
    func fetchThemes() async throws
    func selectTheme(_ theme: Theme?)
    func saveSelectedTheme() async throws
    func deleteTheme(_ theme: Theme) async throws
    func copyTheme(_ theme: Theme) async throws
}

struct DefaultThemeViewModel: ThemeViewModelProtocol {
    var availableThemes: [Theme] = [.snutt, .cherryBlossom, .preview1, .preview2, .preview3]
    var selectedTheme: Theme? = nil
    func fetchThemes() async throws {}
    func selectTheme(_: Theme?) {}
    func saveSelectedTheme() async throws {}
    func deleteTheme(_: Theme) async throws {}
    func copyTheme(_: Theme) async throws {}
}

extension EnvironmentValues {
    @Entry public var themeViewModel: any ThemeViewModelProtocol = DefaultThemeViewModel()
}
