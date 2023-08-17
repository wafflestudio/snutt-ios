//
//  MenuSheetScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/05/27.
//

import SwiftUI

struct MenuSheetScene: View {
    @ObservedObject var viewModel: MenuSheetViewModel

    var body: some View {
        ZStack {
            // TODO: Split these
            MenuSheet(isOpen: $viewModel.isMenuSheetOpen,
                      openCreateSheet: viewModel.openCreateSheet,
                      current: viewModel.currentTimetable,
                      metadataList: viewModel.metadataList,
                      timetablesByQuarter: viewModel.timetablesByQuarter,
                      selectTimetable: viewModel.selectTimetable,
                      duplicateTimetable: viewModel.duplicateTimetable,
                      openEllipsis: viewModel.openEllipsis)

            MenuEllipsisSheet(isOpen: $viewModel.isEllipsisSheetOpen,
                              openRenameSheet: viewModel.openRenameSheet,
                              setPrimaryTimetable: viewModel.setPrimaryTimetable,
                              openThemeSheet: viewModel.openThemeSheet,
                              deleteTimetable: viewModel.deleteTimetable)

            MenuThemeSheet(isOpen: $viewModel.isThemeSheetOpen,
                           selectedTheme: viewModel.selectedTheme,
                           cancel: viewModel.closeThemeSheet,
                           confirm: viewModel.applyThemeSheet,
                           select: viewModel.selectTheme)

            MenuRenameSheet(isOpen: $viewModel.isRenameSheetOpen,
                            titleText: $viewModel.renameTitle,
                            cancel: viewModel.closeRenameSheet,
                            confirm: viewModel.applyRenameSheet)

            MenuCreateSheet(isOpen: $viewModel.isCreateSheetOpen,
                            titleText: $viewModel.createTitle,
                            selectedQuarter: $viewModel.createQuarter,
                            quarterChoices: viewModel.availableCourseBooks,
                            cancel: viewModel.closeCreateSheet,
                            confirm: viewModel.applyCreateSheet)
        }
    }
}

#if DEBUG
    ///// A simple wrapper that is used to preview `MenuSheet`.
    @MainActor
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
                        container.appState.menu.isOpen.toggle()
                    }
                    NavBarButton(imageName: "menu.ellipsis") {
                        container.services.globalUIService.openEllipsis(for: .init(id: "4", year: 2332, semester: 2, title: "32323", isPrimary: false, updatedAt: "3232", totalCredit: 3))
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
#endif
