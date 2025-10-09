//
//  ThemeViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation
import Observation
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
        Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(named: .customThemeDidUpdate).compactMap({ _ in () }
            ) {
                guard let self else { return }
                try? await fetchThemes()
            }
        }
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
