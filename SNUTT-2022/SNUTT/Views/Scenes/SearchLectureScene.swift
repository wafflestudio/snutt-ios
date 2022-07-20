//
//  SearchLectureScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/18.
//

import SwiftUI

struct SearchLectureScene: View {
    @State var searchBarHeight: CGFloat = .zero
    @State var isVisibleRate: CGFloat = 0

    @ObservedObject var viewModel: SearchSceneViewModel
    @ObservedObject var filterSheetSetting: FilterSheetSetting

    init(viewModel: SearchSceneViewModel) {
        self.viewModel = viewModel
        filterSheetSetting = viewModel.filterSheetSetting
    }

    var body: some View {
        ZStack {
            Group {
                VStack {
                    Spacer()
                        .frame(height: 44)
                    TimetableZStack(viewModel: .init(container: viewModel.container))
                        .environmentObject(viewModel.timetableSetting)
                }
                Color.black.opacity(0.3)
            }
            .ignoresSafeArea([.keyboard])
            VStack {
                SearchBar(text: $viewModel.searchText, isFilterOpen: $filterSheetSetting.isOpen)
                Spacer()
            }
        }
        .navigationBarHidden(true)

        let _ = debugChanges()
    }
}

struct SearchLectureScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SearchLectureScene(viewModel: .init(container: .preview))
        }
    }
}
