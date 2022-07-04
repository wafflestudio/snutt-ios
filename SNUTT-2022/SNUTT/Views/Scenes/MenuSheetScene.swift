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
    
    init(viewModel:MenuSheetViewModel) {
        self.viewModel = viewModel
        menuSheetSetting = self.viewModel.menuSheetSetting
    }

    var body: some View {
        MenuSheet(isOpen: $menuSheetSetting.isOpen) {
            Text("helllllo")
        }
    }
}

struct LeftSheetScene_Previews: PreviewProvider {
    static var previews: some View {
        MenuSheetScene(viewModel: .init(appState: AppState()))
    }
}
