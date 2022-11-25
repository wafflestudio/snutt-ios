//
//  GlobalUIService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/06.
//

import Foundation

protocol GlobalUIServiceProtocol {
    func setIsMenuOpen(_ value: Bool) async

    func openEllipsis(for timetable: TimetableMetadata) async
    func closeEllipsis() async

    func openThemeSheet() async
    func closeThemeSheet() async

    func openRenameSheet() async
    func closeRenameSheet() async

    func openCreateSheet(withPicker: Bool) async
    func closeCreateSheet() async

    func setRenameTitle(_ value: String) async
    func setCreateTitle(_ value: String) async
    func setCreateQuarter(_ value: Quarter?) async

    func setIsLectureTimeSheetOpen(_ value: Bool, modifying timePlace: TimePlace?, action: ((TimePlace) -> Void)?) async

    func presentErrorAlert(error: STError?) async
    func presentErrorAlert(error: ErrorCode) async
    func presentErrorAlert(error: Error) async
}

struct GlobalUIService: GlobalUIServiceProtocol, UserAuthHandler {
    var appState: AppState
    var localRepositories: AppEnvironment.LocalRepositories

    @MainActor func setIsMenuOpen(_ value: Bool) async {
        appState.menu.isOpen = value
    }

    @MainActor func openEllipsis(for timetable: TimetableMetadata) async  {
        appState.menu.isEllipsisSheetOpen = true
        appState.menu.ellipsisTarget = timetable
    }

    @MainActor func closeEllipsis() async {
        appState.menu.isEllipsisSheetOpen = false
        appState.menu.ellipsisTarget = nil
    }

    @MainActor func openThemeSheet() async {
        appState.menu.isOpen = false
        appState.menu.isEllipsisSheetOpen = false
        appState.menu.isThemeSheetOpen = true
    }

    @MainActor func closeThemeSheet() async {
        appState.menu.isThemeSheetOpen = false
        appState.timetable.current?.selectedTheme = nil
    }

    @MainActor func openRenameSheet() async {
        appState.menu.renameTitle = appState.menu.ellipsisTarget?.title ?? ""
        appState.menu.isEllipsisSheetOpen = false
        appState.menu.isRenameSheetOpen = true
    }

    @MainActor func closeRenameSheet() async {
        appState.menu.isRenameSheetOpen = false
    }

    @MainActor func openCreateSheet(withPicker: Bool) async {
        appState.menu.createTitle = ""
        appState.menu.createQuarter = withPicker ? appState.timetable.courseBookList?.first : nil
        appState.menu.isCreateSheetOpen = true
    }

    @MainActor func closeCreateSheet() async {
        appState.menu.isCreateSheetOpen = false
    }

    @MainActor func setRenameTitle(_ value: String) async {
        appState.menu.renameTitle = value
    }

    @MainActor func setCreateTitle(_ value: String) async {
        appState.menu.createTitle = value
    }

    @MainActor func setCreateQuarter(_ value: Quarter?) async {
        appState.menu.createQuarter = value
    }

    // MARK: Lecture Time Sheet

    @MainActor func setIsLectureTimeSheetOpen(_ value: Bool, modifying timePlace: TimePlace?, action: ((TimePlace) -> Void)?) async {
        appState.menu.timePlaceToModify = timePlace
        appState.menu.lectureTimeSheetAction = action
        appState.menu.isLectureTimeSheetOpen = value
    }

    // MARK: Error Handling

    @MainActor func presentErrorAlert(error: Error) async {
        await presentErrorAlert(error: error.asSTError)
    }

    @MainActor func presentErrorAlert(error: ErrorCode) async {
        await presentErrorAlert(error: .init(error))
    }

    @MainActor func presentErrorAlert(error: STError?) async {
        guard let error = error else {
            appState.system.isErrorAlertPresented = false
            return
        }

        if error.code == .WRONG_USER_TOKEN || error.code == .NO_USER_TOKEN {
            await clearUserInfo()
        }

        appState.system.error = error
        appState.system.isErrorAlertPresented = true
    }
}
