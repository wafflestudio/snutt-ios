//
//  MenuSheetViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import Foundation

class MenuSheetViewModel: BaseViewModel, ObservableObject {
    
    @Published var currentTimetable: Timetable?
    @Published var metadataList: [TimetableMetadata]?
    @Published var isMenuSheetOpen: Bool = false
    @Published var isEllipsisSheetOpen: Bool = false
    @Published var isThemeSheetOpen: Bool = false
    @Published var isRenameSheetOpen: Bool = false
    @Published var isCreateSheetOpen: Bool = false
    
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
        
        appState.timetable.$current.assign(to: &$currentTimetable)
        appState.timetable.$metadataList.assign(to: &$metadataList)
        appState.menu.$isOpen.assign(to: &$isMenuSheetOpen)
        appState.menu.$isEllipsisSheetOpen.assign(to: &$isEllipsisSheetOpen)
        appState.menu.$isThemeSheetOpen.assign(to: &$isThemeSheetOpen)
        appState.menu.$isRenameSheetOpen.assign(to: &$isRenameSheetOpen)
        appState.menu.$isCreateSheetOpen.assign(to: &$isCreateSheetOpen)
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
    
    var isNewCourseBookAvailable: Bool {
        services.timetableService.isNewCourseBookAvailable()
    }
    
    var timetablesByQuarter: [Quarter: [TimetableMetadata]] {
        return Dictionary(grouping: timetableState.metadataList ?? [], by: { $0.quarter })
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
    
    func openCreateSheet() {
        services.globalUIService.openCreateSheet()
    }
    
    func selectTimetable(timetableId: String) async {
        do {
            await services.searchService.initializeSearchState()
            try await services.timetableService.fetchTimetable(timetableId: timetableId)
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

    func openEllipsis(for timetable: TimetableMetadata) {
        services.globalUIService.openEllipsis(for: timetable)
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
