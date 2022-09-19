//
//  SearchLectureScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/18.
//

import SwiftUI

struct SearchLectureScene: View {
    @ObservedObject var viewModel: SearchSceneViewModel
    var navigationBarHeight: CGFloat

    @State private var reloadSearchList: Int = 0

    var body: some View {
        ZStack {
            GeometryReader { reader in

                // MARK: Background Timetable

                Group {
                    VStack {
                        Spacer()
                            .frame(height: navigationBarHeight)
                        TimetableZStack(current: viewModel.currentTimetableWithSelection,
                                        config: viewModel.timetableConfigWithAutoFit)
                            .animation(.customSpring, value: viewModel.selectedLecture?.id)
                    }
                    STColor.searchListBackground
                }
                .ignoresSafeArea(.keyboard)

                VStack(spacing: 0) {
                    // MARK: SearchBar with padding

                    VStack(spacing: 0) {
                        Spacer()
                        SearchBar(text: $viewModel.searchText,
                                  isFilterOpen: $viewModel.isFilterOpen,
                                  shouldShowCancelButton: viewModel.searchResult != nil,
                                  action: viewModel.fetchInitialSearchResult,
                                  cancel: viewModel.initializeSearchState)
                    }
                    .frame(height: reader.safeAreaInsets.top + navigationBarHeight)

                    // MARK: Selected Filter Tags

                    if viewModel.selectedTagList.count > 0 {
                        SearchTagsScrollView(selectedTagList: viewModel.selectedTagList, deselect: viewModel.deselectTag)
                    }

                    // MARK: Main Content

                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxHeight: .infinity, alignment: .center)
                    } else if viewModel.searchResult == nil {
                        SearchTips()
                    } else if viewModel.searchResult?.count == 0 {
                        EmptySearchResult()
                    } else {
                        SearchLectureList(data: viewModel.searchResult!,
                                          fetchMore: viewModel.fetchMoreSearchResult,
                                          addLecture: viewModel.addLecture,
                                          fetchReviewId: viewModel.fetchReviewId(of:),
                                          selected: $viewModel.selectedLecture)
                            .animation(.customSpring, value: viewModel.selectedLecture?.id)
                            .id(reloadSearchList) // reload everything when any of the search conditions changes
                    }
                }
                .edgesIgnoringSafeArea(.top)
                .ignoresSafeArea(.keyboard)
            }
        }
        .task {
            await viewModel.fetchTags()
        }
        .navigationBarHidden(true)
        .animation(.customSpring, value: viewModel.searchResult?.count)
        .animation(.customSpring, value: viewModel.isLoading)
        .animation(.customSpring, value: viewModel.selectedTagList.count)
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
            SearchLectureScene(viewModel: .init(container: .preview), navigationBarHeight: 80)
        }
    }
}
