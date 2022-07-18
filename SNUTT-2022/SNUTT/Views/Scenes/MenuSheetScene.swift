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
        MenuSheet(isOpen: $menuSheetSetting.isOpen) {
            Text("helllllo")
        }
    }
}

///// A simple wrapper that is used to preview `MenuSheet`.
struct MenuSheetWrapper: View {
    var body: some View {
        let container = DIContainer.preview
        let appState = container.appState
        ZStack {
            NavBarButton(imageName: "nav.menu") {
                appState.setting.menuSheetSetting.isOpen.toggle()
            }
            MenuSheetScene(viewModel: .init(container: .preview))
        }
    }
}

struct MenuSheetScene_Previews: PreviewProvider {
    static var previews: some View {
        MenuSheetWrapper()
    }
}
