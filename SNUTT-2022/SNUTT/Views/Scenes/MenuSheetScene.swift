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
    @FocusState private var titleTextFieldFocus: Bool
    @State private var isDeleteAlertPresented = false

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
            
            Sheet(isOpen: $menuState.isEllipsisOpen, orientation: .bottom(maxHeight: 180)) {
                VStack(spacing: 0) {
                    EllipsisSheetButton(imageName: "pen", text: "이름 변경") {
                        viewModel.openTitleTextField()
                    }
                    
                    EllipsisSheetButton(imageName: "trash", text: "시간표 삭제") {
                        isDeleteAlertPresented = true
                    }
                    .alert("시간표를 삭제하시겠습니까?", isPresented: $isDeleteAlertPresented) {
                        Button("취소", role: .cancel, action: {})
                        Button("삭제", role: .destructive) {
                            Task {
                                await viewModel.deleteTimetable()
                            }
                        }
                    }
                    
                    EllipsisSheetButton(imageName: "palette", text: "시간표 테마 설정") {
                        viewModel.openPalette()
                    }
                }
            }
            
            Sheet(isOpen: $menuState.isThemePaletteOpen, orientation: .bottom(maxHeight: 100)) {
                Text("테마 선택")
            }
            
            Sheet(isOpen: $menuState.isTitleTextFieldOpen, orientation: .bottom(maxHeight: 200), disableBackgroundTap: false, disableDragGesture: false) {
                VStack {
                    HStack {
                        Button {
                            viewModel.cancelTitleTextField()
                        } label: {
                            Text("취소")
                        }

                        Spacer()
                        
                        Button {
                            Task {
                                await viewModel.applyTitleTextField()
                            }
                        } label: {
                            Text("적용")
                        }
                        

                    }
                    TextField("입력하세요", text: $menuState.titleText)
                        .focused($titleTextFieldFocus)
                }
            }
            .onChange(of: menuState.isTitleTextFieldOpen) { newValue in
                titleTextFieldFocus = newValue
            }
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
