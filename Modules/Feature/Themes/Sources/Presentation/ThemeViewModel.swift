//
//  ThemeViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import DependenciesUtility
import Foundation
import Observation
import SwiftUtility
import ThemesInterface

@Observable
@MainActor
public final class ThemeViewModel: ThemeViewModelProtocol {
    @ObservationIgnored
    @Dependency(\.themeRepository) private var themeRepository

    @ObservationIgnored
    @Dependency(\.notificationCenter) private var notificationCenter

    @ObservationIgnored
    @Dependency(\.themeLocalRepository) private var themeLocalRepository

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
        subscribeToNotifications()
    }

    private func subscribeToNotifications() {
        Task.scoped(
            to: self,
            subscribing: notificationCenter.messages(of: CustomThemeDidUpdateMessage.self)
        ) { @MainActor viewModel, _ in
            try? await viewModel.fetchThemes()
        }
    }

    public func fetchThemes() async throws {
        themes = try await themeRepository.fetchThemes()
        themeLocalRepository.storeAvailableThemes(themes)
    }

    public func selectTheme(_ theme: Theme?) {
        selectedTheme = theme
    }

    public func saveSelectedTheme() async throws {
        guard let selectedTheme else { return }
        try await saveSelectedTheme(selectedTheme)
    }

    public func deleteTheme(_ theme: Theme) async throws {
        try await themeRepository.deleteTheme(themeId: theme.id)
        try await fetchThemes()
    }

    public func copyTheme(_ theme: Theme) async throws {
        _ = try await themeRepository.copyTheme(themeId: theme.id)
        try await fetchThemes()
    }
}
