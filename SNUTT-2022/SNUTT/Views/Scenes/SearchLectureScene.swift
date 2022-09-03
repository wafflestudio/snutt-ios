//
//  SearchLectureScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/18.
//

import SwiftUI

struct SearchLectureScene: View {
    let viewModel: SearchSceneViewModel
    @ObservedObject var searchState: SearchState

    @State var previousCount: Int = 0
    
    @State private var reloadSearchList: Int = 0
    
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
                    TimetableZStack(current: viewModel.timetableState.current?.withSelectedLecture(searchState.selectedLecture),
                                    config: viewModel.timetableState.configuration.withAutoFitEnabled())
                        .animation(.customSpring, value: searchState.selectedLecture?.id)
                }
                STColor.searchListBackground
            }
            .ignoresSafeArea(.keyboard)
            
            VStack(spacing: 0) {
                SearchBar(text: $searchState.searchText,
                          isFilterOpen: $searchState.isFilterOpen,
                          shouldShowCancelButton: searchState.searchResult != nil,
                          action: viewModel.fetchInitialSearchResult,
                          cancel: viewModel.initializeSearchState
                )
                
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
                                            Image("xmark.white")
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
                } else if searchState.searchResult == nil {
                    SearchTips()
                } else if searchState.searchResult?.count == 0 {
                    EmptySearchResult()
                } else {
                    SearchLectureList(viewModel: .init(container: viewModel.container),
                                      data: viewModel.searchResult,
                                      fetchMore: viewModel.fetchMoreSearchResult,
                                      selected: $searchState.selectedLecture)
                        .animation(.customSpring, value: searchState.selectedLecture?.id)
                        .id(reloadSearchList)
                }
            }
        }
        .task {
            await viewModel.fetchTags()
        }
        .navigationBarHidden(true)
        .animation(.customSpring, value: searchState.searchResult?.count)
        .animation(.customSpring, value: viewModel.isLoading)
        .onChange(of: viewModel.isLoading) { _ in
            withAnimation(.customSpring) {
                reloadSearchList += 1
                
            }
        }
        
        let _ = debugChanges()
    }
}

private struct SelectedLectureKey: EnvironmentKey {
    static let defaultValue: Lecture? = nil
}

extension EnvironmentValues {
    var selectedLecture: Lecture? {
        get { self[SelectedLectureKey.self] }
        set { self[SelectedLectureKey.self] = newValue }
    }
}

struct SearchLectureList: View {
    let viewModel: ViewModel
    let data: [Lecture]
    let fetchMore: () async -> Void
    @Binding var selected: Lecture?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(data) { lecture in
                    SearchLectureCell(viewModel: .init(container: viewModel.container), lecture: lecture, selected: selected?.id == lecture.id)
                        .task {
                            if lecture.id == data.last?.id {
                                await fetchMore()
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selected?.id != lecture.id {
                                selected = lecture
                            }
                        }
                }
            }
            .padding(.vertical, 5)
        }

        let _ = debugChanges()
    }
}

extension SearchLectureList {
    class ViewModel: BaseViewModel {}
}

struct SearchLectureScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SearchLectureScene(viewModel: .init(container: .preview))
        }
    }
}
