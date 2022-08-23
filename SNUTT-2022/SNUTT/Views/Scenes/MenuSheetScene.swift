//
//  MenuSheetScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/05/27.
//

import SwiftUI

struct MenuSheetScene: View {
    let viewModel: MenuSheetViewModel
    @ObservedObject var menuState: MenuState
    @ObservedObject var timetableState: TimetableState

    init(viewModel: MenuSheetViewModel) {
        self.viewModel = viewModel
        menuState = self.viewModel.menuState
        timetableState = self.viewModel.timetableState
    }

    var body: some View {
        ZStack {
            MenuSheet(viewModel: .init(container: viewModel.container),
                      isOpen: $menuState.isOpen)

            MenuEllipsisSheet(isOpen: $menuState.isEllipsisSheetOpen,
                              openRenameSheet: viewModel.openRenameSheet,
                              deleteTimetable: viewModel.deleteTimetable,
                              openThemeSheet: viewModel.openThemeSheet)

            MenuThemeSheet(isOpen: $menuState.isThemeSheetOpen,
                           selectedTheme: viewModel.selectedTheme,
                           cancel: viewModel.closeThemeSheet,
                           confirm: viewModel.applyThemeSheet,
                           select: viewModel.selectTheme)

            MenuRenameSheet(isOpen: $menuState.isRenameSheetOpen,
                            titleText: $menuState.renameTitle,
                            cancel: viewModel.closeRenameSheet,
                            confirm: viewModel.applyRenameSheet)

            MenuCreateSheet(isOpen: $menuState.isCreateSheetOpen,
                            titleText: $menuState.createTitle,
                            selectedQuarter: $menuState.createQuarter,
                            quarterChoices: viewModel.availableCourseBooks,
                            cancel: viewModel.closeCreateSheet,
                            confirm: viewModel.applyCreateSheet)
        }
    }
}

///// A simple wrapper that is used to preview `MenuSheet`.
struct MenuSheetWrapper: View {
    let container = DIContainer.preview

    init() {
        container.appState.menu.isOpen = true
        container.appState.menu.isEllipsisSheetOpen = true
    }

    var body: some View {
        ZStack {
            HStack {
                NavBarButton(imageName: "nav.menu") {
                    container.services.appService.toggleMenuSheet()
                }
                NavBarButton(imageName: "menu.ellipsis") {
                    container.services.appService.openEllipsis(for: .init(id: "4", year: 2332, semester: 2, title: "32323", updatedAt: "3232", totalCredit: 3))
                }
            }
            MenuSheetScene(viewModel: .init(container: container))
        }
    }
}

struct MenuSheetScene_Previews: PreviewProvider {
    static var previews: some View {
        MenuSheetWrapper()
    }
}
