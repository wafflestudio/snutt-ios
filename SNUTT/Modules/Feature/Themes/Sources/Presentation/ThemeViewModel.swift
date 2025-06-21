//
//  ThemeViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Observation
import Dependencies
import ThemesInterface

@Observable
@MainActor
public final class ThemeViewModel: ThemeViewModelProtocol {
    @ObservationIgnored
    @Dependency(\.themeRepository) private var themeRepository

    public private(set) var themes: [Theme] = []
    public var availableThemes: [Theme] {
        themes
    }
    public private(set) var selectedTheme: Theme?

    private let saveSelectedTheme: @MainActor (Theme) async throws -> Void

    public init(
        saveSelectedTheme: @MainActor @escaping (Theme) async throws -> Void
    ) {
        self.saveSelectedTheme = saveSelectedTheme
    }

    public func fetchThemes() async throws {
        themes = try await themeRepository.fetchThemes()
    }

    public func selectTheme(_ theme: Theme?) {
        selectedTheme = theme
    }

    public func saveSelectedTheme() async throws {
        guard let selectedTheme else { return }
        try await saveSelectedTheme(selectedTheme)
    }
}
