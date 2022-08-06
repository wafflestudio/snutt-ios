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

    init(viewModel: MenuSheetViewModel) {
        self.viewModel = viewModel
        menuState = self.viewModel.menuState
    }
    
    var body: some View {
        ZStack {
            Sheet(isOpen: $menuState.isOpen, orientation: .left(maxWidth: 320), cornerRadius: 0, sheetOpacity: 0.7) {
                VStack(spacing: 0) {
                    HStack {
                        Logo(orientation: .horizontal)
                            .padding(.vertical)
                        Spacer()
                        Button {
                            viewModel.toggleMenuSheet()
                        } label: {
                            Image("xmark.black")
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .padding(.horizontal, 10)
                    
                    MenuSheetContent(viewModel: .init(container: viewModel.container))
                }
            }
            
            MenuEllipsisSheet(isOpen: $menuState.isEllipsisOpen,
                              openTitleTextField: viewModel.openTitleTextField,
                              deleteTimetable: viewModel.deleteTimetable,
                              openPalette: viewModel.openPalette)
            
            Sheet(isOpen: $menuState.isThemePaletteOpen, orientation: .bottom(maxHeight: 100)) {
                Text("테마 선택")
            }
            
            MenuTextFieldSheet(isOpen: $menuState.isTitleTextFieldOpen,
                               titleText: $menuState.titleText,
                               cancel: viewModel.cancelTitleTextField,
                               confirm: viewModel.applyTitleTextField
            )
            
        }
    }
}

///// A simple wrapper that is used to preview `MenuSheet`.
struct MenuSheetWrapper: View {
    let container = DIContainer.preview

    init() {
        container.appState.menu.isOpen = true
        container.appState.menu.isEllipsisOpen = true
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
