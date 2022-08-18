//
//  MenuSheetViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import Foundation

class MenuSheetViewModel: BaseViewModel {
    var menuState: MenuState {
        appState.menu
    }

    var timetableState: TimetableState {
        appState.timetable
    }

    func openPalette() {
        if menuState.ellipsisTarget?.id != appState.timetable.current?.id {
            services.appService.presentErrorAlert(error: .CANT_CHANGE_OTHERS_THEME)
            services.appService.closeEllipsis()
            return
        }
        services.appService.openThemePalette()
    }

    func openTitleTextField() {
        services.appService.openTitleTextField()
    }

    func cancelTitleTextField() {
        services.appService.closeTitleTextField()
    }

    func applyTitleTextField() async {
        guard let timetableId = menuState.ellipsisTarget?.id else { return }
        do {
            try await services.timetableService.updateTimetableTitle(timetableId: timetableId, title: menuState.titleText)
            services.appService.closeTitleTextField()
        } catch {
            services.appService.presentErrorAlert(error: error)
        }
    }

    func deleteTimetable() async {
        guard let timetableId = menuState.ellipsisTarget?.id else { return }
        do {
            try await services.timetableService.deleteTimetable(timetableId: timetableId)
            services.appService.closeEllipsis()
        } catch {
            services.appService.presentErrorAlert(error: error)
        }
    }

    func cancelThemeChange() {
        services.appService.closeThemePalette()
    }

    func applyThemeChange() async {
        guard let timetableId = menuState.ellipsisTarget?.id else { return }

        do {
            try await services.timetableService.updateTimetableTheme(timetableId: timetableId)
            services.appService.closeThemePalette()
        } catch {
            services.appService.presentErrorAlert(error: error)
        }
    }

    func selectTheme(theme: Theme) {
        services.timetableService.selectTimetableTheme(theme: theme)
    }

    var selectedTheme: Theme {
        guard let current = appState.timetable.current else { return .snutt }
        return current.selectedTheme ?? current.theme
    }
}
