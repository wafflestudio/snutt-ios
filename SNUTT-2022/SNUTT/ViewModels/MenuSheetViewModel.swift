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

    func openThemeSheet() {
        if menuState.ellipsisTarget?.id != appState.timetable.current?.id {
            services.globalUIService.presentErrorAlert(error: .CANT_CHANGE_OTHERS_THEME)
            services.globalUIService.closeEllipsis()
            return
        }
        services.globalUIService.openThemeSheet()
    }

    func openRenameSheet() {
        services.globalUIService.openRenameSheet()
    }

    func closeRenameSheet() {
        services.globalUIService.closeRenameSheet()
    }

    func applyRenameSheet() async {
        guard let timetableId = menuState.ellipsisTarget?.id else { return }
        do {
            try await services.timetableService.updateTimetableTitle(timetableId: timetableId, title: menuState.renameTitle)
            services.globalUIService.closeRenameSheet()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func deleteTimetable() async {
        guard let timetableId = menuState.ellipsisTarget?.id else { return }
        do {
            try await services.timetableService.deleteTimetable(timetableId: timetableId)
            services.globalUIService.closeEllipsis()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func closeThemeSheet() {
        services.globalUIService.closeThemeSheet()
    }

    func applyThemeSheet() async {
        guard let timetableId = menuState.ellipsisTarget?.id else { return }

        do {
            try await services.timetableService.updateTimetableTheme(timetableId: timetableId)
            services.globalUIService.closeThemeSheet()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func closeCreateSheet() {
        services.globalUIService.closeCreateSheet()
    }

    func applyCreateSheet() async {
        guard let quarter = menuState.createQuarter else { return }
        do {
            try await services.timetableService.createTimetable(title: menuState.createTitle, quarter: quarter)
            try await services.timetableService.fetchRecentTimetable()
            services.globalUIService.closeCreateSheet()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func selectTheme(theme: Theme) {
        services.timetableService.selectTimetableTheme(theme: theme)
    }

    var selectedTheme: Theme {
        guard let current = appState.timetable.current else { return .snutt }
        return current.selectedTheme ?? current.theme
    }

    var availableCourseBooks: [Quarter] {
        appState.timetable.courseBookList ?? []
    }
}
