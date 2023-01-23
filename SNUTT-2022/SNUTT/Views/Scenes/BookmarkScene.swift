//
//  BookmarkScene.swift
//  SNUTT
//
//  Created by 이채민 on 2023/01/21.
//

import SwiftUI

struct BookmarkScene: View {
    @ObservedObject var viewModel: SearchSceneViewModel
    var navigationBarHeight: CGFloat
    
    @State private var reloadBookmarkList: Int = 0

    var body: some View {
        GeometryReader { reader in
            ZStack {
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
                
                if viewModel.bookmarkedLectures.isEmpty {
                    EmptyBookmarkList()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    SearchLectureList(data: viewModel.bookmarkedLectures,
                                      fetchMore: viewModel.fetchMoreSearchResult,
                                      bookmarkedLecture: viewModel.getBookmarkedLecture,
                                      existingLecture: viewModel.getExistingLecture,
                                      bookmarkLecture: viewModel.bookmarkLecture,
                                      undoBookmarkLecture: viewModel.undoBookmarkLecture,
                                      addLecture: viewModel.addLecture,
                                      deleteLecture: viewModel.deleteLecture,
                                      fetchReviewId: viewModel.fetchReviewId(of:),
                                      overwriteLecture: viewModel.overwriteLecture(lecture:),
                                      preloadReviewWebView: viewModel.preloadReviewWebView(reviewId:),
                                      errorTitle: viewModel.errorTitle,
                                      errorMessage: viewModel.errorMessage,
                                      isLectureOverlapped: $viewModel.isLectureOverlapped,
                                      selected: $viewModel.selectedLecture,
                                      isFirstBookmark: $viewModel.isFirstBookmark)
                        .animation(.customSpring, value: viewModel.selectedLecture?.id)
                        .id(reloadBookmarkList)
                }
            }
        }
        .alert(viewModel.errorTitle, isPresented: $viewModel.isEmailVerifyAlertPresented, actions: {
            Button("확인") {
                viewModel.selectedTab = .review
            }
            Button("취소", role: .cancel) {}
        }, message: {
            Text(viewModel.errorMessage)
        })
        .navigationTitle("관심강좌")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.customSpring, value: viewModel.bookmarkedLectures.count)
        .animation(.customSpring, value: viewModel.isLoading)
        .onAppear {
            Task {
                await viewModel.getBookmark()
            }
        }
        .onChange(of: viewModel.isLoading) { _ in
            withAnimation(.customSpring) {
                reloadBookmarkList += 1
            }
        }
    }
}

struct EmptyBookmarkList: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("추가한 관심강좌가 없습니다.")
                .font(.system(size: 16, weight: .bold))
            Spacer().frame(height: 6)
            Text("고민되는 강의를 관심강좌에 추가하여\n관리해보세요.")
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
        .foregroundColor(STColor.whiteTranslucent)
    }
}

struct BookmarkScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BookmarkScene(viewModel: .init(container: .preview), navigationBarHeight: 80)
        }
    }
}
