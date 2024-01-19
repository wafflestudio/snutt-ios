//
//  ThemeDetailViewModel.swift
//  SNUTT
//
//  Created by 이채민 on 2024/01/17.
//

import SwiftUI
import Combine

class ThemeDetailViewModel: BaseViewModel, ObservableObject {
    
    @Published var currentTimetable: Timetable?
    @Published var configuration: TimetableConfiguration = .init()
    
    override init(container: DIContainer) {
        super.init(container: container)
        appState.timetable.$current.assign(to: &$currentTimetable)
        appState.timetable.$configuration.assign(to: &$configuration)
    }
    
    var themeState: ThemeState {
        appState.theme
    }
    
    func addTheme(theme: Theme) async {
        do {
            try await services.themeService.addTheme(theme: theme)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
        if (theme.isDefault) {
            do {
                try await services.themeService.makeCustomThemeDefault(themeId: theme.id)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
    
    func updateTheme(theme: Theme) async {
        do {
            try await services.themeService.updateTheme(theme: theme)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
        if (theme.isDefault) {
            do {
                try await services.themeService.makeCustomThemeDefault(themeId: theme.id)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        } else {
            do {
                try await services.themeService.undoCustomThemeDefault(themeId: theme.id)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
    
    func saveBasicTheme(theme: Theme) async {
        if (theme.isDefault) {
            do {
                try await services.themeService.makeBasicThemeDefault(themeType: theme.theme?.rawValue ?? 0)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
    
    func getThemeNewColor(theme: Theme) -> Theme {
        var theme = theme
        if (theme.colors.count == 9) { return theme }
        theme.colors.append(.init(fg: Color(hex: "#ffffff"), bg: Color(hex: "#1BD0C8")))
        return theme
    }
    
    func copyThemeColor(theme: Theme, index: Int) -> Theme {
        var theme = theme
        if (theme.colors.count == 9) { return theme }
        theme.colors.insert(theme.colors[index], at: index)
        return theme
    }
    
    func deleteThemeColor(theme: Theme, index: Int) -> Theme {
        var theme = theme
        theme.colors.remove(at: index)
        return theme
    }
}
