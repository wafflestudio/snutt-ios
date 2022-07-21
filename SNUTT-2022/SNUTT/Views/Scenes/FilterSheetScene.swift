//
//  FilterSheetScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/18.
//

import SwiftUI

struct FilterSheetScene: View {
    let viewModel: FilterSheetViewModel
    @ObservedObject var searchState: SearchState

    init(viewModel: FilterSheetViewModel) {
        self.viewModel = viewModel
        searchState = self.viewModel.searchState
    }

    var body: some View {
        Sheet(isOpen: $searchState.isOpen, orientation: .bottom(maxHeight: 500)) {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        searchState.isOpen.toggle()
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
                container.appState.search.isOpen.toggle()
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
