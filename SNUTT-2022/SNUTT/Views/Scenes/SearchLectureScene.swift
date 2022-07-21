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
    @ObservedObject var searchState: SearchState

    init(viewModel: SearchSceneViewModel) {
        self.viewModel = viewModel
        searchState = viewModel.searchState
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
                SearchBar(text: $searchState.searchText, isFilterOpen: $searchState.isOpen) {
                    Task {
                        await viewModel.fetchInitialSearchResult()
                    }
                }
                
                if viewModel.selectedTagList.count > 0 {
                    ScrollViewReader { reader in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.selectedTagList) { tag in
                                    Button(action: {
                                        withAnimation(.customSpring) {
                                            viewModel.toggle(tag)
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
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                        .onChange(of: viewModel.selectedTagList.count, perform: { newValue in
                            if newValue <= previousCount {
                                // no need to scroll when deselecting
                                previousCount = newValue
                                return
                            }
                            withAnimation(.customSpring) {
                                reader.scrollTo(viewModel.selectedTagList.last?.id, anchor: .trailing)
                            }
                            previousCount = newValue
                        })
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxHeight: .infinity, alignment: .center)
                } else {
                    SearchLectureList(data: viewModel.searchResult, fetchMore: viewModel.fetchMoreSearchResult)
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


struct SearchLectureList: View {
    let data: [Lecture]
    let fetchMore: () async -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(data) { lecture in
                    LectureListCell(lecture: lecture, colorMode: .white)
                        .task {
                            if lecture.id == data.last?.id {
                                await fetchMore()
                            }
                        }
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
        }
        .mask(LinearGradient(gradient: Gradient(stops: [
            .init(color: .clear, location: 0),
            .init(color: .black, location: 0.02),
            .init(color: .black, location: 1),
        ]), startPoint: .top, endPoint: .bottom))
        
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
