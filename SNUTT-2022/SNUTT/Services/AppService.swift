//
//  AppService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/06.
//

import Foundation

protocol AppServiceProtocol {
    func toggleMenuSheet()
    func openEllipsis(for timetable: TimetableMetadata)
    func closeEllipsis()
    func openThemePalette()
    func openTitleTextField()
    func closeTitleTextField()
    func presentErrorAlert(error: STError?)
}

/// A service that modifies miscellaneous global states.
struct AppService: AppServiceProtocol {
    var appState: AppState
    
    func toggleMenuSheet() {
        DispatchQueue.main.async {
        appState.menu.isOpen.toggle()
        }
    }
    
    func openEllipsis(for timetable: TimetableMetadata) {
        DispatchQueue.main.async {
        appState.menu.isEllipsisOpen = true
            appState.menu.ellipsisTarget = timetable }
    }
    
    func closeEllipsis() {
        DispatchQueue.main.async {
        appState.menu.isEllipsisOpen = false
        appState.menu.ellipsisTarget = nil
        }
    }
    
    func openThemePalette() {
        DispatchQueue.main.async {
        appState.menu.isOpen = false
        appState.menu.isEllipsisOpen = false
        appState.menu.isThemePaletteOpen = true
        }
    }
    
    func openTitleTextField() {
        DispatchQueue.main.async {
        appState.menu.titleText = appState.menu.ellipsisTarget?.title ?? ""
        appState.menu.isEllipsisOpen = false
        appState.menu.isTitleTextFieldOpen = true
        }
    }
    
    func closeTitleTextField() {
        DispatchQueue.main.async {
            appState.menu.isTitleTextFieldOpen = false
        }
    }
    
    // MARK: error handling
    
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
