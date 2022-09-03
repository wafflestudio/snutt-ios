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

    @State private var reloadSearchList: Int = 0
    
    init(viewModel: SearchSceneViewModel) {
        self.viewModel = viewModel
        searchState = viewModel.searchState
    }

    var body: some View {
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
                    SearchTagsScrollView(selectedTagList: viewModel.selectedTagList, deselect: viewModel.toggle)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxHeight: .infinity, alignment: .center)
                } else if searchState.searchResult == nil {
                    SearchTips()
                } else if searchState.searchResult?.count == 0 {
                    EmptySearchResult()
                } else {
                    SearchLectureList(data: viewModel.searchResult,
                                      fetchMore: viewModel.fetchMoreSearchResult,
                                      addLecture: viewModel.addLecture,
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

struct SearchLectureScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SearchLectureScene(viewModel: .init(container: .preview))
        }
    }
}
