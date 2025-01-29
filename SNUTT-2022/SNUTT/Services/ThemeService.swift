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
    func openDownloadedThemeSheet(for theme: Theme)
    func closeDownloadedThemeSheet()

    func getThemeList() async throws
    func addTheme(theme: Theme, apply: Bool) async throws
    func updateTheme(themeId: String, theme: Theme) async throws
    func copyTheme(themeId: String) async throws
    func deleteTheme(themeId: String) async throws
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
        appState.theme.bottomSheetTarget = theme
        appState.timetable.current?.selectedTheme = theme
        appState.theme.isNewThemeSheetOpen = true
    }

    func closeNewThemeSheet() {
        appState.timetable.current?.selectedTheme = nil
        appState.theme.isNewThemeSheetOpen = false
        appState.theme.bottomSheetTarget = nil
    }

    func openBasicThemeSheet(for theme: Theme) {
        appState.theme.bottomSheetTarget = theme
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
    
    func openDownloadedThemeSheet(for _: Theme) {
        appState.theme.isDownloadedThemeSheetOpen = true
        appState.theme.isBottomSheetOpen = false
    }

    func closeDownloadedThemeSheet() {
        appState.timetable.current?.selectedTheme = nil
        appState.theme.isDownloadedThemeSheetOpen = false
        appState.theme.bottomSheetTarget = nil
    }

    func getThemeList() async throws {
        let dtos = try await themeRepository.getThemeList()
        let themeList = dtos.map { Theme(from: $0) }
        appState.theme.themeList = themeList
    }

    func addTheme(theme: Theme, apply: Bool) async throws {
        let dto = try await themeRepository.addTheme(name: theme.name, colors: theme.colors.map { ThemeColorDto(from: $0) })
        let themeData = Theme(from: dto)
        if apply {
            guard let timetableId = appState.timetable.current?.id else { return }
            let dto = try await timetableRepository.updateTimetableTheme(withTimetableId: timetableId, withTheme: themeData)
            let timetable = Timetable(from: dto)
            if appState.timetable.current?.id == timetableId {
                appState.timetable.current = timetable
            }
        }
        let dtos = try await themeRepository.getThemeList()
        let themeList = dtos.map { Theme(from: $0) }
        appState.theme.themeList = themeList
    }

    func updateTheme(themeId: String, theme: Theme) async throws {
        let _ = try await themeRepository.updateTheme(themeId: themeId, name: theme.name, colors: theme.colors.map { ThemeColorDto(from: $0) })
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

    private var themeRepository: ThemeRepositoryProtocol {
        webRepositories.themeRepository
    }

    private var timetableRepository: TimetableRepositoryProtocol {
        webRepositories.timetableRepository
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
    func openDownloadedThemeSheet(for _: Theme) {}
    func closeDownloadedThemeSheet() {}

    func getThemeList() async throws {}
    func addTheme(theme _: Theme, apply _: Bool) async throws {}
    func updateTheme(themeId _: String, theme _: Theme) async throws {}
    func copyTheme(themeId _: String) async throws {}
    func deleteTheme(themeId _: String) async throws {}
}
