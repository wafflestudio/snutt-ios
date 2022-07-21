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
    
    @State var previousCount: Int = 0

    @ObservedObject var viewModel: SearchSceneViewModel
    @ObservedObject var filterSheetSetting: FilterSheetSetting

    init(viewModel: SearchSceneViewModel) {
        self.viewModel = viewModel
        filterSheetSetting = viewModel.filterSheetSetting
    }
    
    var body: some View {
        // TODO: Split components
        ZStack {
            Group {
                VStack {
                    Spacer()
                        .frame(height: 44)
                    TimetableZStack(viewModel: .init(container: viewModel.container))
                        .environmentObject(viewModel.timetableSetting)
                }
                Color.black.opacity(0.6)
            }
            .ignoresSafeArea([.keyboard])
            
            VStack(spacing: 0) {
                SearchBar(text: $filterSheetSetting.searchText, isFilterOpen: $filterSheetSetting.isOpen) {
                    Task {
                        await viewModel.fetchInitialSearchResult()
                    }
                }
                
                if viewModel.selectedCount > 0 {
                    ScrollViewReader { reader in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.getSelectedTagList()) { tag in
                                    Button(action: {
                                        withAnimation(.customSpring) {
                                            viewModel.toggle(tag)
                                            Task {
                                                await viewModel.fetchInitialSearchResult()
                                            }
                                        }
                                    }, label: {
                                        HStack {
                                            Text(tag.text)
                                                .font(.system(size: 14))
                                            Image("xmark")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 10)
                                        }
                                    })
                                    .buttonStyle(.borderedProminent)
                                    .buttonBorderShape(.capsule)
                                    .tint(tag.type.tagLightColor)
                                    .id(tag.id)
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                        .frame(height: 50, alignment: .center)
                        .onChange(of: viewModel.selectedCount, perform: { newValue in
                            if newValue <= previousCount {
                                // no need to scroll when deselecting
                                previousCount = newValue
                                return
                            }
                            withAnimation(.customSpring) {
                                reader.scrollTo(viewModel.getSelectedTagList().last?.id, anchor: .trailing)
                            }
                            previousCount = newValue
                        })
                    }
                }
                
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.searchResult) { lecture in
                            LectureListCell(lecture: lecture, colorMode: .white)
                                .task {
                                    if lecture.id == viewModel.searchResult.last?.id {
                                        await viewModel.fetchMoreSearchResult()
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 15)
                }
            }
        }
        .task {
            await viewModel.fetchTags()
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
