//
//  MenuSheetViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import Combine
import SwiftUI

class MenuSheetViewModel: BaseViewModel, ObservableObject {
    @Published var currentTimetable: Timetable?
    @Published var metadataList: [TimetableMetadata]?

    @Published private var _isMenuSheetOpen: Bool = false
    var isMenuSheetOpen: Bool {
        get { _isMenuSheetOpen }
        set { Task { await services.globalUIService.setIsMenuOpen(newValue) }}
    }

    @Published private var _isEllipsisSheetOpen: Bool = false
    var isEllipsisSheetOpen: Bool {
        get { _isEllipsisSheetOpen }
        set { Task { await services.globalUIService.closeEllipsis() }} // close-only; the sheets can't open themselves
    }

    @Published private var _isThemeSheetOpen: Bool = false
    var isThemeSheetOpen: Bool {
        get { _isThemeSheetOpen }
        set { Task { await services.globalUIService.closeThemeSheet() }} // close-only;
    }

    @Published private var _isRenameSheetOpen: Bool = false
    var isRenameSheetOpen: Bool {
        get { _isRenameSheetOpen }
        set { Task { await services.globalUIService.closeRenameSheet() } } // close-only;
    }

    @Published private var _isCreateSheetOpen: Bool = false
    var isCreateSheetOpen: Bool {
        get { _isCreateSheetOpen }
        set { Task { await services.globalUIService.closeCreateSheet() }} // close-only;
    }

    @Published private var _renameTitle: String = ""
    var renameTitle: String {
        get { _renameTitle }
        set { Task { await services.globalUIService.setRenameTitle(newValue) } }
    }

    @Published private var _createTitle: String = ""
    var createTitle: String {
        get { _createTitle }
        set { Task { await services.globalUIService.setCreateTitle(newValue) }}
    }

    @Published private var _createQuarter: Quarter?
    var createQuarter: Quarter? {
        get { _createQuarter }
        set { Task { await services.globalUIService.setCreateQuarter(newValue) }}
    }

    override init(container: DIContainer) {
        super.init(container: container)

        appState.menu.$isOpen.assign(to: &$_isMenuSheetOpen)
        appState.menu.$isEllipsisSheetOpen.assign(to: &$_isEllipsisSheetOpen)
        appState.menu.$isThemeSheetOpen.assign(to: &$_isThemeSheetOpen)
        appState.menu.$isRenameSheetOpen.assign(to: &$_isRenameSheetOpen)
        appState.menu.$isCreateSheetOpen.assign(to: &$_isCreateSheetOpen)
        appState.timetable.$current.assign(to: &$currentTimetable)
        appState.timetable.$metadataList.assign(to: &$metadataList)
        appState.menu.$renameTitle.assign(to: &$_renameTitle)
        appState.menu.$createTitle.assign(to: &$_createTitle)
        appState.menu.$createQuarter.assign(to: &$_createQuarter)
    }

    var menuState: MenuState {
        appState.menu
    }

    var timetableState: TimetableState {
        appState.timetable
    }

    var latestEmptyQuarter: Quarter? {
        services.courseBookService.getLatestEmptyQuarter()
    }

    var timetablesByQuarter: [Quarter: [TimetableMetadata]] {
        var dict = Dictionary(grouping: timetableState.metadataList ?? [], by: { $0.quarter })
        if let latestEmptyQuarter = latestEmptyQuarter {
            dict[latestEmptyQuarter] = []
        }
        return dict
    }

    func openThemeSheet() async {
        if menuState.ellipsisTarget?.id != appState.timetable.current?.id {
            await services.globalUIService.presentErrorAlert(error: .CANT_CHANGE_OTHERS_THEME)
            await services.globalUIService.closeEllipsis()
            return
        }
        await services.globalUIService.openThemeSheet()
    }

    func openRenameSheet() async {
        await services.globalUIService.openRenameSheet()
    }

    func closeRenameSheet() async {
        await services.globalUIService.closeRenameSheet()
    }

    func openCreateSheet(withPicker: Bool) {
        Task {
            await services.globalUIService.openCreateSheet(withPicker: withPicker)
        }
    }

    func selectTimetable(timetableId: String) async {
        do {
            await services.searchService.initializeSearchState()
            try await services.timetableService.fetchTimetable(timetableId: timetableId)
        } catch {
            await services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func duplicateTimetable(timetableId: String) async {
        do {
            try await services.timetableService.copyTimetable(timetableId: timetableId)
        } catch {
            await services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func openEllipsis(for timetable: TimetableMetadata) {
        Task {
            await services.globalUIService.openEllipsis(for: timetable)
        }
    }

    func applyRenameSheet() async {
        guard let timetableId = menuState.ellipsisTarget?.id else { return }
        do {
            try await services.timetableService.updateTimetableTitle(timetableId: timetableId, title: menuState.renameTitle)
            await services.globalUIService.closeRenameSheet()
        } catch {
            await services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func deleteTimetable() async {
        guard let timetableId = menuState.ellipsisTarget?.id else { return }
        do {
            try await services.timetableService.deleteTimetable(timetableId: timetableId)
            await services.globalUIService.closeEllipsis()
        } catch {
            await services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func closeThemeSheet() async {
        await services.globalUIService.closeThemeSheet()
    }

    func applyThemeSheet() async {
        guard let timetableId = menuState.ellipsisTarget?.id else { return }

        do {
            try await services.timetableService.updateTimetableTheme(timetableId: timetableId)
            await services.globalUIService.closeThemeSheet()
        } catch {
            await services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func closeCreateSheet() async {
        await services.globalUIService.closeCreateSheet()
    }

    func applyCreateSheet() async {
        guard let quarter = menuState.createQuarter ?? latestEmptyQuarter else { return }
        do {
            try await services.timetableService.createTimetable(title: menuState.createTitle, quarter: quarter)
            try await services.timetableService.fetchRecentTimetable() // change current timetable to newly created one
            await services.globalUIService.closeCreateSheet()
        } catch {
            await services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func selectTheme(theme: Theme) async {
        await services.timetableService.selectTimetableTheme(theme: theme)
    }

    var selectedTheme: Theme {
        guard let current = appState.timetable.current else { return .snutt }
        return current.selectedTheme ?? current.theme
    }

    var availableCourseBooks: [Quarter] {
        appState.timetable.courseBookList ?? []
    }
}
