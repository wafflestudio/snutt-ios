//
//  ThemeService.swift
//  SNUTT
//
//  Created by 이채민 on 2024/01/17.
//

import Foundation
import SwiftUI

@MainActor
protocol ThemeServiceProtocol: Sendable {
    func openBottomSheet(for theme: Theme)
    func closeBottomSheet()
    func openNewThemeSheet(for theme: Theme)
    func closeNewThemeSheet()
    func openBasicThemeSheet(for theme: Theme)
    func closeBasicThemeSheet()
    func openCustomThemeSheet(for theme: Theme)
    func closeCustomThemeSheet()

    func getThemeList() async throws
    func addTheme(theme: Theme) async throws
    func updateTheme(themeId: String, theme: Theme) async throws
    func copyTheme(themeId: String) async throws
    func deleteTheme(themeId: String) async throws
    func makeBasicThemeDefault(themeType: Int) async throws
    func undoBasicThemeDefault(themeType: Int) async throws
    func makeCustomThemeDefault(themeId: String) async throws
    func undoCustomThemeDefault(themeId: String) async throws
}

struct ThemeService: ThemeServiceProtocol {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories
    var localRepositories: AppEnvironment.LocalRepositories

    func openBottomSheet(for theme: Theme) {
        appState.theme.bottomSheetTarget = theme
        appState.theme.isBottomSheetOpen = true
    }

    func closeBottomSheet() {
        appState.theme.isBottomSheetOpen = false
        appState.theme.bottomSheetTarget = nil
    }

    func openNewThemeSheet(for theme: Theme) {
        appState.timetable.current?.selectedTheme = theme
        appState.theme.isNewThemeSheetOpen = true
    }

    func closeNewThemeSheet() {
        appState.timetable.current?.selectedTheme = nil
        appState.theme.isNewThemeSheetOpen = false
    }

    func openBasicThemeSheet(for _: Theme) {
        appState.theme.isBasicThemeSheetOpen = true
        appState.theme.isBottomSheetOpen = false
    }

    func closeBasicThemeSheet() {
        appState.timetable.current?.selectedTheme = nil
        appState.theme.isBasicThemeSheetOpen = false
        appState.theme.bottomSheetTarget = nil
    }

    func openCustomThemeSheet(for _: Theme) {
        appState.theme.isCustomThemeSheetOpen = true
        appState.theme.isBottomSheetOpen = false
    }

    func closeCustomThemeSheet() {
        appState.timetable.current?.selectedTheme = nil
        appState.theme.isCustomThemeSheetOpen = false
        appState.theme.bottomSheetTarget = nil
    }

    func getThemeList() async throws {
        let dtos = try await themeRepository.getThemeList()
        let themeList = dtos.map { Theme(from: $0) }
        appState.theme.themeList = themeList
    }

    func addTheme(theme: Theme) async throws {
        let dto = try await themeRepository.addTheme(name: theme.name, colors: theme.colors.map { ThemeColorDto(from: $0) })
        let themeData = Theme(from: dto)
        if theme.isDefault {
            let _ = try await themeRepository.makeCustomThemeDefault(themeId: themeData.id)
        }
        let dtos = try await themeRepository.getThemeList()
        let themeList = dtos.map { Theme(from: $0) }
        appState.theme.themeList = themeList
    }

    func updateTheme(themeId: String, theme: Theme) async throws {
        let dto = try await themeRepository.updateTheme(themeId: themeId, name: theme.name, colors: theme.colors.map { ThemeColorDto(from: $0) })
        let themeData = Theme(from: dto)
        let _ = theme.isDefault ? try await themeRepository.makeCustomThemeDefault(themeId: themeData.id) : try await themeRepository.undoCustomThemeDefault(themeId: themeData.id)
        appState.theme.bottomSheetTarget = theme
        let dtos = try await themeRepository.getThemeList()
        let themeList = dtos.map { Theme(from: $0) }
        appState.theme.themeList = themeList
    }

    func copyTheme(themeId: String) async throws {
        let _ = try await themeRepository.copyTheme(themeId: themeId)
        let dtos = try await themeRepository.getThemeList()
        let themeList = dtos.map { Theme(from: $0) }
        appState.theme.themeList = themeList
    }

    func deleteTheme(themeId: String) async throws {
        try await themeRepository.deleteTheme(themeId: themeId)
        let dtos = try await themeRepository.getThemeList()
        let themeList = dtos.map { Theme(from: $0) }
        appState.theme.themeList = themeList
    }

    func makeBasicThemeDefault(themeType: Int) async throws {
        let _ = try await themeRepository.makeBasicThemeDefault(themeType: themeType)
        let dtos = try await themeRepository.getThemeList()
        let themeList = dtos.map { Theme(from: $0) }
        appState.theme.themeList = themeList
    }

    func undoBasicThemeDefault(themeType: Int) async throws {
        let _ = try await themeRepository.undoBasicThemeDefault(themeType: themeType)
        let dtos = try await themeRepository.getThemeList()
        let themeList = dtos.map { Theme(from: $0) }
        appState.theme.themeList = themeList
    }

    func makeCustomThemeDefault(themeId: String) async throws {
        let _ = try await themeRepository.makeCustomThemeDefault(themeId: themeId)
        let dtos = try await themeRepository.getThemeList()
        let themeList = dtos.map { Theme(from: $0) }
        appState.theme.themeList = themeList
    }

    func undoCustomThemeDefault(themeId: String) async throws {
        let _ = try await themeRepository.undoCustomThemeDefault(themeId: themeId)
        let dtos = try await themeRepository.getThemeList()
        let themeList = dtos.map { Theme(from: $0) }
        appState.theme.themeList = themeList
    }

    private var themeRepository: ThemeRepositoryProtocol {
        webRepositories.themeRepository
    }
}

struct FakeThemeService: ThemeServiceProtocol {
    func openBottomSheet(for _: Theme) {}
    func closeBottomSheet() {}
    func openNewThemeSheet(for _: Theme) {}
    func closeNewThemeSheet() {}
    func openBasicThemeSheet(for _: Theme) {}
    func closeBasicThemeSheet() {}
    func openCustomThemeSheet(for _: Theme) {}
    func closeCustomThemeSheet() {}

    func getThemeList() async throws {}
    func addTheme(theme _: Theme) async throws {}
    func updateTheme(themeId _: String, theme _: Theme) async throws {}
    func copyTheme(themeId _: String) async throws {}
    func deleteTheme(themeId _: String) async throws {}
    func makeBasicThemeDefault(themeType _: Int) async throws {}
    func undoBasicThemeDefault(themeType _: Int) async throws {}
    func makeCustomThemeDefault(themeId _: String) async throws {}
    func undoCustomThemeDefault(themeId _: String) async throws {}
}
