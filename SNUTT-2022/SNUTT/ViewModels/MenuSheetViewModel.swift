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
    
    func toggleMenuSheet() {
        services.appService.toggleMenuSheet()
    }
    
    func openPalette() {
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
            try await services.timetableService.updateTimetableTitle(timetableId: timetableId, withTitle: menuState.titleText)
            services.appService.closeTitleTextField()
        } catch {
            services.appService.presentErrorAlert(error: error.asSTError)
        }
    }
    
    func deleteTimetable() async {
        guard let timetableId = menuState.ellipsisTarget?.id else { return }
        do {
            try await services.timetableService.deleteTimetable(timetableId: timetableId)
                services.appService.closeEllipsis()
        } catch {
            services.appService.presentErrorAlert(error: error.asSTError)
        }
    }
}
