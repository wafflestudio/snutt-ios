//
//  GlobalUIService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/06.
//

import Foundation
import SwiftUI

protocol GlobalUIServiceProtocol {
    func setIsMenuOpen(_ val: Bool)

    func openEllipsis(for timetable: TimetableMetadata)
    func closeEllipsis()

    func openThemeSheet()
    func closeThemeSheet()

    func openRenameSheet()
    func closeRenameSheet()

    func openCreateSheet()
    func closeCreateSheet()

    func setRenameTitle(_ val: String)
    func setCreateTitle(_ val: String)
    func setCreateQuarter(_ val: Quarter?)

    func presentErrorAlert(error: STError?)
    func presentErrorAlert(error: Error)
}

/// A service that modifies miscellaneous global states.
struct GlobalUIService: GlobalUIServiceProtocol {
    var appState: AppState

    func setIsMenuOpen(_ val: Bool) {
        DispatchQueue.main.async {
            appState.menu.isOpen = val
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

    func openCreateSheet() {
        DispatchQueue.main.async {
            appState.menu.createTitle = ""
            appState.menu.createQuarter = appState.timetable.courseBookList?.first
            appState.menu.isCreateSheetOpen = true
        }
    }

    func closeCreateSheet() {
        DispatchQueue.main.async {
            appState.menu.isCreateSheetOpen = false
        }
    }

    func setRenameTitle(_ val: String) {
        appState.menu.renameTitle = val
    }

    func setCreateTitle(_ val: String) {
        appState.menu.createTitle = val
    }

    func setCreateQuarter(_ val: Quarter?) {
        appState.menu.createQuarter = val
    }

    // MARK: error handling

    func presentErrorAlert(error: Error) {
        presentErrorAlert(error: error.asSTError)
    }

    func presentErrorAlert(error: STError?) {
        guard let error = error else {
            return
        }
        DispatchQueue.main.async {
            appState.system.errorContent = error
            appState.system.isErrorAlertPresented = true
        }
    }
}