//
//  SearchLectureScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/18.
//

import SwiftUI

struct SearchLectureScene: View {
    @State var searchBarHeight: CGFloat = .zero
    
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
                        .frame(height: searchBarHeight)
                    
                    TimetableZStack()
                        .environmentObject(viewModel.currentTimetable)
                        .environmentObject(viewModel.timetableSetting)
                }
                
                Color.black.opacity(0.3)
            }
            .ignoresSafeArea([.keyboard])
            
            VStack {
                SearchBar(text: $viewModel.searchText, isFilterOpen: $filterSheetSetting.isOpen)
                    .readSize { size in
                        searchBarHeight = size.height
                    }
                Spacer()
            }
        }
        
        let _ = debugChanges()
    }
}

// TODO: move elsewhere
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

struct SearchLectureScene_Previews: PreviewProvider {
    static var previews: some View {
        SearchLectureScene(viewModel: .init(appState: AppState()))
    }
}
