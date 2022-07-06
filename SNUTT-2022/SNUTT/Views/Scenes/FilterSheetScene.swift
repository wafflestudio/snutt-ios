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
        Sheet(isOpen: $filterSheetSetting.isOpen, orientation: .bottom(maxHeight: 500)) {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        filterSheetSetting.isOpen.toggle()
                    } label: {
                        Image("xmark")
                    }
                }
                .padding(20)
                Spacer()
                FilterSheetContent()
                Spacer()
            }
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
