//
//  GlobalUIService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/06.
//

import Foundation

protocol GlobalUIServiceProtocol {
    func setIsMenuOpen(_ value: Bool)

    func openEllipsis(for timetable: TimetableMetadata)
    func closeEllipsis()

    func openThemeSheet()
    func closeThemeSheet()

    func openRenameSheet()
    func closeRenameSheet()

    func openCreateSheet(withPicker: Bool)
    func closeCreateSheet()

    func setRenameTitle(_ value: String)
    func setCreateTitle(_ value: String)
    func setCreateQuarter(_ value: Quarter?)

    func setIsLectureTimeSheetOpen(_ value: Bool, modifying timePlace: TimePlace?, action: ((TimePlace) -> Void)?)

    func presentErrorAlert(error: STError?)
    func presentErrorAlert(error: ErrorCode)
    func presentErrorAlert(error: Error)
}

struct GlobalUIService: GlobalUIServiceProtocol, UserAuthHandler {
    var appState: AppState
    var localRepositories: AppEnvironment.LocalRepositories

    @MainActor func setIsMenuOpen(_ value: Bool) {
        appState.menu.isOpen = value
    }

    @MainActor func openEllipsis(for timetable: TimetableMetadata) {
        appState.menu.isEllipsisSheetOpen = true
        appState.menu.ellipsisTarget = timetable
    }

    @MainActor func closeEllipsis() {
        appState.menu.isEllipsisSheetOpen = false
        appState.menu.ellipsisTarget = nil
    }

    @MainActor func openThemeSheet() {
        appState.menu.isOpen = false
        appState.menu.isEllipsisSheetOpen = false
        appState.menu.isThemeSheetOpen = true
    }

    @MainActor func closeThemeSheet() {
        appState.menu.isThemeSheetOpen = false
        appState.timetable.current?.selectedTheme = nil
    }

    @MainActor func openRenameSheet() {
        appState.menu.renameTitle = appState.menu.ellipsisTarget?.title ?? ""
        appState.menu.isEllipsisSheetOpen = false
        appState.menu.isRenameSheetOpen = true
    }

    @MainActor func closeRenameSheet() {
        appState.menu.isRenameSheetOpen = false
    }

    @MainActor func openCreateSheet(withPicker: Bool) {
        appState.menu.createTitle = ""
        appState.menu.createQuarter = withPicker ? appState.timetable.courseBookList?.first : nil
        appState.menu.isCreateSheetOpen = true
    }

    @MainActor func closeCreateSheet() {
        appState.menu.isCreateSheetOpen = false
    }

    @MainActor func setRenameTitle(_ value: String) {
        appState.menu.renameTitle = value
    }

    @MainActor func setCreateTitle(_ value: String) {
        appState.menu.createTitle = value
    }

    @MainActor func setCreateQuarter(_ value: Quarter?) {
        appState.menu.createQuarter = value
    }

    // MARK: Lecture Time Sheet

    @MainActor func setIsLectureTimeSheetOpen(_ value: Bool, modifying timePlace: TimePlace?, action: ((TimePlace) -> Void)?) {
        appState.menu.timePlaceToModify = timePlace
        appState.menu.lectureTimeSheetAction = action
        appState.menu.isLectureTimeSheetOpen = value
    }

    // MARK: Error Handling

    @MainActor func presentErrorAlert(error: Error) {
        presentErrorAlert(error: error.asSTError)
    }

    @MainActor func presentErrorAlert(error: ErrorCode) {
        presentErrorAlert(error: .init(error))
    }

    @MainActor func presentErrorAlert(error: STError?) {
        guard let error = error else {
            appState.system.isErrorAlertPresented = false
            return
        }

        if error.code == .WRONG_USER_TOKEN || error.code == .NO_USER_TOKEN {
            clearUserInfo()
        }

        appState.system.error = error
        appState.system.isErrorAlertPresented = true
    }
}
