//
//  MenuSheetScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/05/27.
//

import SwiftUI

struct MenuSheetScene: View {
    let viewModel: MenuSheetViewModel
    @ObservedObject var menuSheetSetting: MenuSheetSetting

    init(viewModel: MenuSheetViewModel) {
        self.viewModel = viewModel
        menuSheetSetting = self.viewModel.menuSheetSetting
    }

    var body: some View {
        Sheet(isOpen: $menuSheetSetting.isOpen, orientation: .left(maxWidth: 290), cornerRadius: 0) {
            Text("helllllo")
        }
    }
}

///// A simple wrapper that is used to preview `MenuSheet`.
struct MenuSheetWrapper: View {
    let appState = AppState()
    var body: some View {
        ZStack {
            NavBarButton(imageName: "nav.menu") {
                appState.setting.menuSheetSetting.isOpen.toggle()
            }
            MenuSheetScene(viewModel: .init(appState: appState))
        }
    }
}

struct MenuSheetScene_Previews: PreviewProvider {
    static var previews: some View {
        MenuSheetWrapper()
    }
}
