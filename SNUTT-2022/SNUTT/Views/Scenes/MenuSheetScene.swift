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
        Sheet(isOpen: $menuState.isOpen, orientation: .left(maxWidth: 320), cornerRadius: 0, sheetOpacity: 0.7) {
            VStack {
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
                    .padding([.horizontal, .bottom], 10)

                MenuSheetContent(viewModel: .init(container: viewModel.container))
            }
        }
    }
}

///// A simple wrapper that is used to preview `MenuSheet`.
struct MenuSheetWrapper: View {
    let container = DIContainer.preview

    init() {
        container.appState.menu.isOpen = true
    }

    var body: some View {
        ZStack {
            NavBarButton(imageName: "nav.menu") {
                container.services.appService.toggleMenuSheet()
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
