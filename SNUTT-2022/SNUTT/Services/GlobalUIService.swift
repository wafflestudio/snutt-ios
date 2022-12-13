//
//  GlobalUIService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/06.
//

import Foundation
import SwiftUI

protocol GlobalUIServiceProtocol {
    func setColorScheme(_ colorScheme: ColorScheme?)
    func loadColorSchemeDuringBootstrap()
    
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
    
    func setColorScheme(_ colorScheme: ColorScheme?) {
        DispatchQueue.main.async {
            appState.system.preferredColorScheme = colorScheme
        }
        localRepositories.userDefaultsRepository.set(String.self, key: .preferredColorScheme, value: colorScheme?.description)
    }
    
    func loadColorSchemeDuringBootstrap() {
        let colorSchemeDescription = localRepositories.userDefaultsRepository.get(String.self, key: .preferredColorScheme)
        let colorScheme = ColorScheme.from(description: colorSchemeDescription)
        appState.system.preferredColorScheme = colorScheme
    }

    func setIsMenuOpen(_ value: Bool) {
        DispatchQueue.main.async {
            appState.menu.isOpen = value
        }
    }

    func openEllipsis(for timetable: TimetableMetadata) {
        DispatchQueue.main.async {
            appState.menu.isEllipsisSheetOpen = true
            appState.menu.ellipsisTarget = timetable
        }
    }

    func closeEllipsis() {
        DispatchQueue.main.async {
            appState.menu.isEllipsisSheetOpen = false
            appState.menu.ellipsisTarget = nil
        }
    }

    func openThemeSheet() {
        DispatchQueue.main.async {
            appState.menu.isOpen = false
            appState.menu.isEllipsisSheetOpen = false
            appState.menu.isThemeSheetOpen = true
        }
    }

    func closeThemeSheet() {
        DispatchQueue.main.async {
            appState.menu.isThemeSheetOpen = false
            appState.timetable.current?.selectedTheme = nil
        }
    }

    func openRenameSheet() {
        DispatchQueue.main.async {
            appState.menu.renameTitle = appState.menu.ellipsisTarget?.title ?? ""
            appState.menu.isEllipsisSheetOpen = false
            appState.menu.isRenameSheetOpen = true
        }
    }

    func closeRenameSheet() {
        DispatchQueue.main.async {
            appState.menu.isRenameSheetOpen = false
        }
    }

    func openCreateSheet(withPicker: Bool) {
        DispatchQueue.main.async {
            appState.menu.createTitle = ""
            appState.menu.createQuarter = withPicker ? appState.timetable.courseBookList?.first : nil
            appState.menu.isCreateSheetOpen = true
        }
    }

    func closeCreateSheet() {
        DispatchQueue.main.async {
            appState.menu.isCreateSheetOpen = false
        }
    }

    func setRenameTitle(_ value: String) {
        DispatchQueue.main.async {
            appState.menu.renameTitle = value
        }
    }

    func setCreateTitle(_ value: String) {
        DispatchQueue.main.async {
            appState.menu.createTitle = value
        }
    }

    func setCreateQuarter(_ value: Quarter?) {
        DispatchQueue.main.async {
            appState.menu.createQuarter = value
        }
    }

    // MARK: Lecture Time Sheet

    func setIsLectureTimeSheetOpen(_ value: Bool, modifying timePlace: TimePlace?, action: ((TimePlace) -> Void)?) {
        DispatchQueue.main.async {
            appState.menu.timePlaceToModify = timePlace
            appState.menu.lectureTimeSheetAction = action
            appState.menu.isLectureTimeSheetOpen = value
        }
    }

    // MARK: Error Handling

    func presentErrorAlert(error: Error) {
        presentErrorAlert(error: error.asSTError)
    }

    func presentErrorAlert(error: ErrorCode) {
        presentErrorAlert(error: .init(error))
    }

    func presentErrorAlert(error: STError?) {
        guard let error = error else {
            appState.system.isErrorAlertPresented = false
            return
        }

        if error.code == .WRONG_USER_TOKEN || error.code == .NO_USER_TOKEN {
            clearUserInfo()
        }

        DispatchQueue.main.async {
            appState.system.error = error
            appState.system.isErrorAlertPresented = true
        }
    }
}
