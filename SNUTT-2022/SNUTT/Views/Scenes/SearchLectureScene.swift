//
//  SearchLectureScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/18.
//

import SwiftUI

struct SearchLectureScene: View {
    @State private var previousCount: Int = 0
    @ObservedObject var viewModel: SearchSceneViewModel

    var body: some View {
        // TODO: Split components
        ZStack {
            Group {
                VStack {
                    Spacer()
                        .frame(height: 44)
                    TimetableZStack(current: viewModel.currentTimetableWithSelection,
                                    config: viewModel.timetableConfigWithAutoFit)
                        .animation(.customSpring, value: viewModel.selectedLecture?.id)
                }
                STColor.searchListBackground
            }
            .ignoresSafeArea(.keyboard)

            VStack(spacing: 0) {
                // MARK: 검색창

                SearchBar(text: $viewModel.searchText,
                          isFilterOpen: $viewModel.isFilterOpen) {
                    Task {
                        await viewModel.fetchInitialSearchResult()
                    }
                }

                // MARK: 검색 태그

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

                // MARK: 검색 결과

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxHeight: .infinity, alignment: .center)
                } else {
                    SearchLectureList(viewModel: .init(container: viewModel.container),
                                      data: viewModel.searchResult,
                                      fetchMore: viewModel.fetchMoreSearchResult,
                                      selected: $viewModel.selectedLecture)
                        .animation(.customSpring, value: viewModel.selectedLecture?.id)
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
