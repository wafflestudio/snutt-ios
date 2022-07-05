//
//  FilterSheetScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/18.
//

import SwiftUI

struct FilterSheetScene: View {
    let viewModel: FilterSheetViewModel
    @ObservedObject var filterSheetSetting: FilterSheetSetting

    init(viewModel: FilterSheetViewModel) {
        self.viewModel = viewModel
        filterSheetSetting = self.viewModel.filterSheetSetting
    }
    
    var body: some View {
        FilterSheet(isOpen: $filterSheetSetting.isOpen) {
            FilterSheetContent()
        }
    }
}

///// A simple wrapper that is used to preview `FilterSheet`.
struct FilterSheetWrapper: View {
    let appState = AppState()
    var body: some View {
        ZStack {
            NavBarButton(imageName: "search.filter") {
                appState.setting.filterSheetSetting.isOpen.toggle()
            }
            FilterSheetScene(viewModel: .init(appState: appState))
        }
    }
}

struct FilterSheetScene_Previews: PreviewProvider {
    static var previews: some View {
        FilterSheetWrapper()
    }
}
