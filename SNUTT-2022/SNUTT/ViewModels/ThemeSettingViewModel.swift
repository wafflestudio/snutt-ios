//
//  ThemeSettingViewModel.swift
//  SNUTT
//
//  Created by 이채민 on 2024/01/17.
//

import Combine
import SwiftUI

class ThemeSettingViewModel: BaseViewModel, ObservableObject {
    @Published private var themes: [Theme] = []

    var customThemes: [Theme] {
        themes.filter { $0.isCustom }
    }

    var basicThemes: [Theme] {
        themes.filter { !$0.isCustom }
    }

    @Published private var _isBottomSheetOpen: Bool = false
    var isBottomSheetOpen: Bool {
        get { _isBottomSheetOpen }
        set {
            _isBottomSheetOpen = false
            services.themeService.closeBottomSheet()
        }
    }

    @Published private var _isNewThemeSheetOpen: Bool = false
    var isNewThemeSheetOpen: Bool {
        get { _isNewThemeSheetOpen }
        set {
            _isNewThemeSheetOpen = false
            services.themeService.closeNewThemeSheet()
        }
    }

    @Published private var _isBasicThemeSheetOpen: Bool = false
    var isBasicThemeSheetOpen: Bool {
        get { _isBasicThemeSheetOpen }
        set {
            _isBasicThemeSheetOpen = false
            services.themeService.closeBasicThemeSheet()
        }
    }

    @Published private var _isCustomThemeSheetOpen: Bool = false
    var isCustomThemeSheetOpen: Bool {
        get { _isCustomThemeSheetOpen }
        set {
            _isCustomThemeSheetOpen = false
            services.themeService.closeCustomThemeSheet()
        }
    }

    override init(container: DIContainer) {
        super.init(container: container)
        appState.theme.$themeList.assign(to: &$themes)
        appState.theme.$isBottomSheetOpen.assign(to: &$_isBottomSheetOpen)
        appState.theme.$isNewThemeSheetOpen.assign(to: &$_isNewThemeSheetOpen)
        appState.theme.$isBasicThemeSheetOpen.assign(to: &$_isBasicThemeSheetOpen)
        appState.theme.$isCustomThemeSheetOpen.assign(to: &$_isCustomThemeSheetOpen)
    }

    var themeState: ThemeState {
        appState.theme
    }

    var targetTheme: Theme? {
        themeState.bottomSheetTarget
    }

    var newTheme: Theme {
        let theme: Theme = .init(from: .init(id: UUID().uuidString, theme: 0, name: "새 테마", colors: [ThemeColorDto(bg: STColor.cyan.toHex(), fg: Color.white.toHex())], isDefault: false, isCustom: true))
        return theme
    }

    func openBottomSheet(for theme: Theme) {
        services.themeService.openBottomSheet(for: theme)
    }

    func openNewThemeSheet() {
        services.themeService.openNewThemeSheet(for: newTheme)
    }

    func openBasicThemeSheet(for theme: Theme) {
        services.timetableService.selectTimetableTheme(theme: theme)
        services.themeService.openBasicThemeSheet(for: theme)
    }

    func openCustomThemeSheet() {
        guard let theme = targetTheme else { return }
        services.timetableService.selectTimetableTheme(theme: theme)
        services.themeService.openCustomThemeSheet(for: theme)
    }

    func copyTheme() async {
        guard let themeId = targetTheme?.id else { return }
        do {
            try await services.themeService.copyTheme(themeId: themeId)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
        services.themeService.closeBottomSheet()
    }

    func deleteTheme() async {
        guard let themeId = targetTheme?.id else { return }
        do {
            try await services.themeService.deleteTheme(themeId: themeId)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
        services.themeService.closeBottomSheet()
    }
}
