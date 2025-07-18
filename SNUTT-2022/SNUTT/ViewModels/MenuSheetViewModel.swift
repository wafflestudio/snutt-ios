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
    @Published var targetTimetable: Timetable?
    @Published private(set) var configuration: TimetableConfiguration = .init()
    @Published var metadataList: [TimetableMetadata]?
    @Published var themes: [Theme] = []

    @Published private var _isMenuSheetOpen: Bool = false
    var isMenuSheetOpen: Bool {
        get { _isMenuSheetOpen }
        set {
            _isMenuSheetOpen = newValue
            services.globalUIService.setIsMenuOpen(newValue)
        }
    }

    @Published private var _isEllipsisSheetOpen: Bool = false
    var isEllipsisSheetOpen: Bool {
        get { _isEllipsisSheetOpen }
        set {
            _isEllipsisSheetOpen = false
            services.globalUIService.closeEllipsis()
        } // close-only; the sheets can't open themselves
    }

    @Published private var _isThemeSheetOpen: Bool = false
    var isThemeSheetOpen: Bool {
        get { _isThemeSheetOpen }
        set {
            _isThemeSheetOpen = false
            services.globalUIService.closeThemeSheet()
        } // close-only;
    }

    @Published private var _isNewThemeSheetOpen: Bool = false
    var isNewThemeSheetOpen: Bool {
        get { _isNewThemeSheetOpen }
        set {
            _isNewThemeSheetOpen = false
            services.themeService.closeNewThemeSheet()
        } // close-only;
    }

    @Published private var _isRenameSheetOpen: Bool = false
    var isRenameSheetOpen: Bool {
        get { _isRenameSheetOpen }
        set {
            _isRenameSheetOpen = false
            services.globalUIService.closeRenameSheet()
        } // close-only;
    }

    @Published private var _isCreateSheetOpen: Bool = false
    var isCreateSheetOpen: Bool {
        get { _isCreateSheetOpen }
        set {
            _isCreateSheetOpen = false
            services.globalUIService.closeCreateSheet()
        } // close-only;
    }

    @Published private var _renameTitle: String = ""
    var renameTitle: String {
        get { _renameTitle }
        set { services.globalUIService.setRenameTitle(newValue) }
    }

    @Published private var _createTitle: String = ""
    var createTitle: String {
        get { _createTitle }
        set { services.globalUIService.setCreateTitle(newValue) }
    }

    @Published private var _createQuarter: Quarter?
    var createQuarter: Quarter? {
        get { _createQuarter }
        set { services.globalUIService.setCreateQuarter(newValue) }
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
        appState.theme.$themeList.assign(to: &$themes)
        appState.theme.$isNewThemeSheetOpen.assign(to: &$_isNewThemeSheetOpen)
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

    var targetMetaTimetable: TimetableMetadata? {
        menuState.ellipsisTarget
    }

    func getThemeList() async {
        do {
            try await services.themeService.getThemeList()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func openThemeSheet() {
        if targetMetaTimetable?.id != appState.timetable.current?.id {
            services.globalUIService.presentErrorAlert(error: .CANT_CHANGE_OTHERS_THEME)
            services.globalUIService.closeEllipsis()
            return
        }
        services.globalUIService.openThemeSheet()
    }

    var newTheme: Theme {
        let theme: Theme = .init(
            id: UUID().uuidString,
            name: "새 테마",
            colors: [LectureColor(fg: Color.white, bg: STColor.cyan)],
            isCustom: true
        )
        return theme
    }

    func openNewThemeSheet() {
        services.themeService.openNewThemeSheet(for: newTheme)
    }

    func openRenameSheet() {
        services.globalUIService.openRenameSheet()
    }

    func closeRenameSheet() {
        services.globalUIService.closeRenameSheet()
    }

    func openCreateSheet(withPicker: Bool) {
        services.globalUIService.openCreateSheet(withPicker: withPicker)
    }

    func selectTimetable(timetableId: String) async {
        do {
            services.searchService.initializeSearchState()
            if try await services.timetableService.fetchTimetable(timetableId: timetableId) {
                try await services.searchService.getBookmark()
            }
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func duplicateTimetable(timetableId: String) async {
        do {
            try await services.timetableService.copyTimetable(timetableId: timetableId)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func openEllipsis(for timetable: TimetableMetadata) async {
        services.globalUIService.openEllipsis(for: timetable)
        do {
            targetTimetable = try await services.timetableService.fetchTimetableData(timetableId: timetable.id)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func applyRenameSheet() async {
        guard let timetableId = targetMetaTimetable?.id else { return }
        do {
            try await services.timetableService.updateTimetableTitle(
                timetableId: timetableId,
                title: menuState.renameTitle
            )
            services.globalUIService.closeRenameSheet()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func setPrimaryTimetable() async {
        guard let timetableId = targetMetaTimetable?.id else { return }
        do {
            try await services.timetableService.setPrimaryTimetable(timetableId: timetableId)
            services.globalUIService.closeEllipsis()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func unsetPrimaryTimetable() async {
        guard let timetableId = targetMetaTimetable?.id else { return }
        do {
            try await services.timetableService.unsetPrimaryTimetable(timetableId: timetableId)
            services.globalUIService.closeEllipsis()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func deleteTimetable() async {
        guard let timetableId = targetMetaTimetable?.id else { return }
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
        guard let timetableId = targetMetaTimetable?.id else { return }

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
        guard let quarter = menuState.createQuarter ?? latestEmptyQuarter else { return }
        do {
            try await services.timetableService.createTimetable(title: menuState.createTitle, quarter: quarter)
            try await services.timetableService.fetchRecentTimetable() // change current timetable to newly created one
            services.globalUIService.closeCreateSheet()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func selectTheme(theme: Theme) {
        services.timetableService.selectTimetableTheme(theme: theme)
    }

    var selectedTheme: Theme? {
        guard let current = appState.timetable.current else { return nil }
        return current.selectedTheme
    }

    var availableCourseBooks: [Quarter] {
        appState.timetable.courseBookList ?? []
    }
}
