//
//  ThemeDetailViewModel.swift
//  SNUTT
//
//  Created by 이채민 on 2024/01/17.
//

import Combine
import SwiftUI

class ThemeDetailViewModel: BaseViewModel, ObservableObject {
    @Published var isErrorAlertPresented: Bool = false
    var errorTitle: String = ""
    var errorMessage: String = ""

    @Published var currentTimetable: Timetable?
    @Published var configuration: TimetableConfiguration = .init()

    override init(container: DIContainer) {
        super.init(container: container)
        appState.timetable.$current.assign(to: &$currentTimetable)
        appState.timetable.$configuration.assign(to: &$configuration)
        appState.timetable.current?.selectedTheme.map { selectedTheme in
            currentTimetable?.selectedTheme = selectedTheme
        }
    }

    var themeState: ThemeState {
        appState.theme
    }

    var targetTheme: Theme? {
        themeState.bottomSheetTarget
    }

    func addTheme(theme: Theme) async -> Bool {
        do {
            try await services.themeService.addTheme(theme: theme)
            return true
        } catch let error as STError where error.code == .DUPLICATE_THEME_NAME {
            isErrorAlertPresented = true
            errorTitle = error.title
            errorMessage = error.content
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
        return false
    }

    func updateTheme(theme: Theme) async -> Bool {
        guard let themeId = targetTheme?.id else { return false }
        do {
            try await services.themeService.updateTheme(themeId: themeId, theme: theme)
            return true
        } catch let error as STError where error.code == .DUPLICATE_THEME_NAME {
            isErrorAlertPresented = true
            errorTitle = error.title
            errorMessage = error.content
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
        return false
    }

    func saveBasicTheme(theme: Theme) async -> Bool {
        if let themeType = theme.theme {
            do {
                theme.isDefault ? try await services.themeService.makeBasicThemeDefault(themeType: themeType.rawValue) : try await services.themeService.undoBasicThemeDefault(themeType: themeType.rawValue)
                return true
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
        return false
    }

    func getThemeNewColor(theme: Theme) -> Theme {
        var theme = theme
        if theme.colors.count == 9 { return theme }
        theme.colors.append(LectureColor(fg: Color.white, bg: STColor.cyan))
        return theme
    }

    func copyThemeColor(theme: Theme, index: Int) -> Theme {
        var theme = theme
        if theme.colors.count == 9 { return theme }
        theme.colors.insert(theme.colors[index], at: index)
        return theme
    }

    func deleteThemeColor(theme: Theme, index: Int) -> Theme {
        var theme = theme
        theme.colors.remove(at: index)
        return theme
    }
}
