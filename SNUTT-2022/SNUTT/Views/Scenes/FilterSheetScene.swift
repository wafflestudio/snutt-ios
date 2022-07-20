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
                            .padding([.horizontal, .top], 10)
                    }
                }
                .padding(10)
                Spacer()
                FilterSheetContent(viewModel: viewModel)
                Spacer()
            }
        }
    }
}

///// A simple wrapper that is used to preview `FilterSheet`.
struct FilterSheetWrapper: View {
    let container: DIContainer = .preview
    var body: some View {
        ZStack {
            NavBarButton(imageName: "search.filter") {
                container.appState.setting.filterSheetSetting.isOpen.toggle()
            }
            FilterSheetScene(viewModel: .init(container: container))
        }
    }
}

struct FilterSheetScene_Previews: PreviewProvider {
    static var previews: some View {
        FilterSheetWrapper()
    }
}
